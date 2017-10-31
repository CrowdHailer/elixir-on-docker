defmodule WWW.PublishAMessage do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(%{body: body}, _state) do
    %{"message" => message} = URI.decode_www_form(body) |> URI.decode_query()

    {:ok, _} = WWW.Chat.publish(message)

    Raxx.response(:see_other)
    |> Raxx.set_header("location", "/")
  end
end
