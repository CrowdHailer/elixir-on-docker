defmodule WaterCooler.WWW.PublishMessage do
  use Raxx.Server

  alias WaterCooler.ChatRoom
  require ChatRoom

  @impl Raxx.Server
  def handle_request(%{body: body}, _config) do
    {:ok, %{message: message}} = parse_publish_form(body)
    {:ok, _} = ChatRoom.publish(message)

    Raxx.response(:see_other)
    |> Raxx.set_header("location", "/")
  end

  def parse_publish_form(raw) do
    %{"message" => message} = URI.decode_www_form(raw) |> URI.decode_query()
    {:ok, %{message: message}}
  end
end
