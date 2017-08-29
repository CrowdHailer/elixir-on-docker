defmodule WaterCooler.WWW do
  defmodule HomePage do
    use Raxx.Server

    require EEx

    EEx.function_from_file(:defp, :home_page, Path.join(__DIR__, "./templates/home_page.html.eex"), [])

    def handle_headers(request, config) do
      body = home_page()
      Raxx.Response.new(:ok, [{"content-type", "text/html"}], body)
    end
  end

  defmodule SubscribeToMessages do
    use Raxx.Server

    alias WaterCooler.ChatRoom
    require ChatRoom

    def handle_headers(request, config) do
      {:ok, _} = ChatRoom.join()
      response = Raxx.Response.new(:ok, [{"content-type", "text/event-stream"}], true)
      response
    end

    def handle_info(ChatRoom.post(data), config) do
      data = ServerSentEvent.serialize(%ServerSentEvent{lines: [data], type: "chat"})
      {[%{data: data, end_stream: false}], config}
    end
  end

  defmodule PublishMessage do
    use Raxx.Server

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
  use Raxx.Blueprint, [
    {"/", [
      GET: HomePage,
      POST: PublishMessage]},
    {"/updates", [
      GET: SubscribeToMessages
    ]}
  ]
end
