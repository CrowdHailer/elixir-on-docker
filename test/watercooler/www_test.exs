defmodule WaterCooler.WWWTest do
  use ExUnit.Case

  alias WaterCooler.{ChatRoom, WWW}
  require ChatRoom

  setup  do
    # TODO use certificate helpers
    {:ok, service} = Ace.HTTP.Service.start_link({WWW, :config}, [port: 0, cleartext: true])
    {:ok, port} = Ace.HTTP.Service.port(service)
    {:ok, %{port: port}}
  end

  test "Home page is available", %{port: port} do
    {:ok, response} = HTTPoison.get("localhost:#{port}/")
    assert response.status_code == 200
  end

  test "Favicon is available", %{port: port} do
    {:ok, response} = HTTPoison.get("localhost:#{port}/favicon.ico")
    assert response.status_code == 200
  end

  # issue with 404 in router
  @tag :skip
  test "Random page is not found", %{port: port} do
    {:ok, response} = HTTPoison.get("localhost:#{port}/random")
    assert response.status_code == 404
  end

  test "Can post a message", %{port: port} do
    ChatRoom.join()
    {:ok, response} = HTTPoison.post("localhost:#{port}/", "message=Hello")
    assert response.status_code == 303
    assert_receive ChatRoom.post("Hello"), 1_000
  end
  #
  test "Update is streamed to client", %{port: port} do
    {:ok, %{id: _ref}} = HTTPoison.get("localhost:#{port}/updates", %{}, stream_to: self())

    assert_receive %{code: 200}, 1_000
    assert_receive %{headers: headers}, 1_000
    assert "chunked" == :proplists.get_value("transfer-encoding", headers)

    ChatRoom.publish("Greetings!")
    assert_receive %{chunk: chunk}, 1000
    {event, _} = ServerSentEvent.parse(chunk)
    assert %{type: "chat", lines: ["Greetings!"]} = event
  end

end
