defmodule Raxx.Blueprint do
  @moduledoc """
  Route requests based on API Blueprint
  """

  # elements should be api elements in the future
  defmacro __using__(blueprint) do
    actions = blueprint_to_actions(blueprint)

    routing_ast = for {method, path, module} <- actions do
      path = path_template_to_match(path)
      quote do
        def handle_headers(request = %{method: unquote(method), path: unquote(path)}, state) do
          # DEBT live in a state, needs message monad
          Process.put({Raxx.Blueprint, :handler}, unquote(module))
          return = unquote(module).handle_headers(request, state)
        end
      end
    end

    quote do
      use Raxx.App
      unquote(routing_ast)

      def handle_fragment(fragment, state) do
        module = Process.get({Raxx.Blueprint, :handler})
        module.handle_fragment(fragment, state)
      end

      def handle_trailers(trailers, state) do
        module = Process.get({Raxx.Blueprint, :handler})
        module.handle_trailers(trailers, state)
      end

      def handle_info(info, state) do
        module = Process.get({Raxx.Blueprint, :handler})
        module.handle_info(info, state)
      end
    end
  end

  defp blueprint_to_actions(parsed) do
    Enum.flat_map(parsed, fn({path, actions}) ->
      Enum.map(actions, fn({method, module}) ->
        {method, path, module}
      end)
    end)
  end

  defp path_template_to_match(path_template) do
    path_template
    |> Raxx.Request.split_path()
    |> Enum.map(&template_segment_to_match/1)
  end

  defp template_segment_to_match(segment) do
    case String.split(segment, ~r/[{}]/) do
      [raw] ->
        raw
      ["", _name, ""] ->
        Macro.var(:_, nil)
    end
  end
end

defmodule WaterCooler.WWW do
  defmodule HomePage do
    use Raxx.App

    require EEx

    EEx.function_from_file(:defp, :home_page, Path.join(__DIR__, "./templates/home_page.html.eex"), [])

    def handle_headers(request, config) do
      body = home_page()
      Raxx.Response.new(:ok, [{"content-type", "text/html"}], body)
    end
  end

  defmodule SubscribeToMessages do
    use Raxx.App

    alias WaterCooler.ChatRoom
    require ChatRoom

    def handle_headers(request, config) do
      {:ok, _} = ChatRoom.join()
      response = Raxx.Response.new(:ok, [{"content-type", "text/event-stream"}], true)
      response
    end
  end

  defmodule PublishMessage do
    use Raxx.App

    alias WaterCooler.ChatRoom
    require ChatRoom

    def handle_headers(request, config) do
      {[], {:reading, ""}}
    end

    def handle_fragment(fragment, {:reading, buffer}) do
      {[], {:reading, buffer <> fragment}}
    end

    def handle_trailers([], {:reading, body}) do
      {:ok, %{message: message}} = parse_publish_form(body)
      {:ok, _} = ChatRoom.publish(message)
      response = Raxx.Response.new(303, [{"location", "/"}], false)
    end

    def parse_publish_form(raw) do
      %{"message" => message} = URI.decode_www_form(raw) |> URI.decode_query
      {:ok, %{message: message}}
    end

  end
  def PublishMessage do
    use Raxx.Unary

    def handle_request(request, config) do
      {:ok, %{message: message}} = parse_publish_form(request.body)
      {:ok, _} = ChatRoom.publish(message)
      Raxx.Response.new(303, [{"location", "/"}], false)
    end
  end
  use Raxx.Blueprint, [
    {"/", [
      GET: HomePage,
      POST: PublishMessage]},
    {"/updates", [
      GET: SubscribeToMessages
    ]}
  ]

  alias WaterCooler.ChatRoom
  require ChatRoom
  require EEx

  EEx.function_from_file(:defp, :home_page, Path.join(__DIR__, "./templates/home_page.html.eex"), [])

  EEx.function_from_file(:defp, :not_found, Path.join(__DIR__, "./templates/not_found.html.eex"), [])

  def start_link() do
    GenServer.start_link(__MODULE__, :ready)
  end

  def handle_info({stream, request}, :ready) do
    case {request.method, request.path} do
      {:GET, "/"} ->
        body = home_page()
        response = Ace.Response.new(200, [], body)
        Ace.HTTP2.Server.send_response(stream, response)
        {:noreply, :done}
      {:GET, "/updates"} ->
        {:ok, _} = ChatRoom.join()
        response = Ace.Response.new(200, [{"content-type", "text/event-stream"}], true)
        Ace.HTTP2.Server.send_response(stream, response)
        {:noreply, {:updates, stream}}
      {:POST, "/"} ->
        true = request.body
        {:noreply, :reading}
      {:GET, _} ->
        body = not_found()
        response = Ace.Response.new(404, [], body)
        Ace.HTTP2.Server.send_response(stream, response)
        {:noreply, :done}
    end
  end

  def handle_info({stream, %{data: body, end_stream: true}}, :reading) do
    {:ok, %{message: message}} = parse_publish_form(body)
    {:ok, _} = ChatRoom.publish(message)

    response = Ace.Response.new(303, [{"location", "/"}], false)
    Ace.HTTP2.Server.send_response(stream, response)
    {:stop, :normal, :reading}
  end

  def handle_info(ChatRoom.post(data), {:updates, stream}) do
    data = ServerSentEvent.serialize(%ServerSentEvent{lines: [data], type: "chat"})
    Ace.HTTP2.Server.send_data(stream, data)
    {:noreply, {:updates, stream}}
  end
  def handle_info({stream, {:reset, :cancel}}, {:updates, stream}) do
    {:stop, :normal, {:updates, stream}}
  end

  def parse_publish_form(raw) do
    %{"message" => message} = URI.decode_www_form(raw) |> URI.decode_query
    {:ok, %{message: message}}
  end
end
