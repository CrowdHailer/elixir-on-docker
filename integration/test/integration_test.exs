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

  @tag :skip
  test "Random page is not found" do
    {:ok, response} = HTTPoison.get("www:8080/random")
    assert response.status_code == 404
  end
end
