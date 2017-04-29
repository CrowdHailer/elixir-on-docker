defmodule WaterCooler.WWW do

  use Tokumei
  alias WaterCooler.ChatRoom
  require ChatRoom

  @route_name :home
  route [], request do
    :GET ->
      Response.ok(render("home_page.html", %{}))
    :POST ->
      {:ok, %{message: message}} = parse_publish_form(request.body)
      {:ok, _} = ChatRoom.publish(message)
      Helpers.redirect("/")
  end

  @route_name :updates
  route ["updates"] do
    :GET ->
      {:ok, _} = ChatRoom.join()
      %Ace.ChunkedResponse{
        status: 200,
        headers: [
          {"cache-control", "no-cache"},
          {"transfer-encoding", "chunked"},
          {"connection", "keep-alive"},
          {"content-type", "text/event-stream"}
        ]
      }
  end

  def handle_info(ChatRoom.post(data), _) do
    data = ServerSentEvent.serialize(%ServerSentEvent{lines: [data], type: "chat"})
    [data]
  end

  error %NotFoundError{} do
    Raxx.Response.not_found(render("not_found.html", %{}))
  end

  def parse_publish_form(raw) do
    %{"message" => message} = URI.decode_www_form(raw) |> URI.decode_query
    {:ok, %{message: message}}
  end
end
