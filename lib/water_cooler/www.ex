defmodule WaterCooler.WWW do
  use GenServer

  alias WaterCooler.ChatRoom
  require ChatRoom
  require ChatRoom

  require EEx

  EEx.function_from_file(:defp, :home_page, Path.join(__DIR__, "./templates/home_page.html.eex"), [])
  EEx.function_from_file(:defp, :not_found, Path.join(__DIR__, "./templates/not_found.html.eex"), [])

  def start_link() do
    GenServer.start_link(__MODULE__, :ready)
  end

  def handle_info({stream, request}, :ready) do
    case {request.method, request.path} do
      {"GET", "/"} ->
        body = home_page()
        response = Ace.Response.new(200, [], body)
        Ace.HTTP2.Server.send_response(stream, response)
        {:noreply, :done}
      {"GET", "/updates"} ->
        {:ok, _} = ChatRoom.join()
        response = Ace.Response.new(200, [{"content-type", "text/event-stream"}], true)
        Ace.HTTP2.Server.send_response(stream, response)
        {:noreply, {:updates, stream}}
      {"POST", "/"} ->
        true = request.body
        {:noreply, :reading}
      {"GET", _} ->
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
