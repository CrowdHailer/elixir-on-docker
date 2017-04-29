defmodule WaterCooler.WWWTest do
  use ExUnit.Case

  alias Raxx.Request

  alias WaterCooler.{ChatRoom, WWW}
  require ChatRoom

  test "Home page is available" do
    response = get(:home)
    assert response.status == 200
  end

  test "Random page is not found" do
    response = get("/random")
    assert response.status == 404
  end

  test "Can post a message" do
    ChatRoom.join()
    response = post(:home, "message=Hello")
    assert response.status == 303
    assert_receive ChatRoom.post("Hello"), 1_000
  end

  test "Update is streamed to client" do
    response = get(:updates)
    assert "chunked" == :proplists.get_value("transfer-encoding", response.headers)
    assert [chunk] = info(ChatRoom.post("Greetings!"))
    {event, _} = ServerSentEvent.parse(chunk)
    assert %{type: "chat", lines: ["Greetings!"]} = event
  end

  def get(resource) when is_atom(resource) do
    resource
    |> WWW.path_to()
    |> get()
  end
  def get(path) when is_binary(path) do
    path
    |> Request.get()
    |> WWW.handle_request(nil)
  end

  def post(resource, body) when is_atom(resource) do
    resource
    |> WWW.path_to()
    |> post(body)
  end
  def post(path, body) when is_binary(path) do
    path
    |> Request.post(body)
    |> WWW.handle_request(nil)
  end

  def info(message) do
    message
    |> WWW.handle_info(nil)
  end
end
