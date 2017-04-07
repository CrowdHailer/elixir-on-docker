defmodule WaterCooler do
  use Tokumei

  alias WaterCooler.ChatRoom

  config :port, 8080
  config :static, "./public"
  config :templates, "./templates"

  route [], request do
    :GET ->
      ok(__MODULE__.home_page())
    :POST ->
      {:ok, %{message: message}} = parse_publish_form(request.body)
      {:ok, _} = ChatRoom.publish(message)
      redirect("/")
  end

  route ["updates"] do
    :GET ->
      {:ok, _} = ChatRoom.join()
      SSE.stream()
  end

  SSE.streaming do
    {:message, message} ->
      {:send, message}
  end

  def parse_publish_form(raw) do
    %{"message" => message} = URI.decode_www_form(raw) |> URI.decode_query
    {:ok, %{message: message}}
  end
end
