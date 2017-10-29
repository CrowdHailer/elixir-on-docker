defmodule IntegrationTest do
  use ExUnit.Case

  test "Home page is available" do
    {:ok, response} = HTTPoison.get("www:8080/")
    assert response.status_code == 200
  end

  test "Favicon is available" do
    {:ok, response} = HTTPoison.get("www:8080/favicon.ico")
    assert response.status_code == 200
  end

  test "Random page is not found" do
    {:ok, response} = HTTPoison.get("www:8080/random")
    assert response.status_code == 404
  end

  test "Can post a message" do
    {:ok, %{id: updates_ref}} = HTTPoison.get("www:8080/updates", %{}, stream_to: self())

    assert_receive %{id: ^updates_ref, code: 200}, 1000
    assert_receive %{id: ^updates_ref, headers: headers}, 1000
    assert "chunked" == :proplists.get_value("transfer-encoding", headers)

    {:ok, response} = HTTPoison.post("www:8080/", "message=Hello")
    assert response.status_code == 303

    assert_receive %{id: ^updates_ref, chunk: chunk}, 1000
    {event, _} = ServerSentEvent.parse(chunk)
    assert %{type: "chat", lines: ["Hello"]} = event
  end
end
