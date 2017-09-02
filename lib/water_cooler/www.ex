defmodule WaterCooler.WWW do
  @external_resource "./www.apib"

  use Raxx.Blueprint, "./www.apib"
  use Raxx.Static, "./public"

  defmodule HomePage do
    use Raxx.Server

    require EEx

    EEx.function_from_file(:defp, :home_page, Path.join(__DIR__, "./templates/home_page.html.eex"), [])

    def handle_headers(_request, _config) do
      body = home_page()
      Raxx.response(:ok)
      |> Raxx.set_header("content-type", "text/html")
      |> Raxx.set_body(body)
    end
  end

  defmodule SubscribeToMessages do
    use Raxx.Server

    alias WaterCooler.ChatRoom
    require ChatRoom

    def handle_headers(_request, _config) do
      {:ok, _} = ChatRoom.join()
      Raxx.response(:ok)
      |> Raxx.set_header("content-type", "text/event-stream")
      |> Raxx.set_body(true)
    end

    def handle_info(ChatRoom.post(data), config) do
      data = ServerSentEvent.serialize(%ServerSentEvent{lines: [data], type: "chat"})
      fragment = Raxx.fragment(data)
      {[fragment], config}
    end
  end

  defmodule PublishMessage do
    use Raxx.Server

    alias WaterCooler.ChatRoom
    require ChatRoom

    def handle_headers(_request, _config) do
      {[], {:reading, ""}}
    end

    def handle_fragment(fragment, {:reading, buffer}) do
      {[], {:reading, buffer <> fragment}}
    end

    def handle_trailers([], {:reading, body}) do
      {:ok, %{message: message}} = parse_publish_form(body)
      {:ok, _} = ChatRoom.publish(message)
      Raxx.response(:see_other)
      |> Raxx.set_header("location", "/")
    end

    def parse_publish_form(raw) do
      %{"message" => message} = URI.decode_www_form(raw) |> URI.decode_query
      {:ok, %{message: message}}
    end

  end

end
