defmodule WWW.SubscribeToUpdates do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(_request, state) do
    {:ok, _} = WWW.Chat.join()

    response = Raxx.response(:ok)
    |> Raxx.set_header("content-type", "text/event-stream")
    |> Raxx.set_body(true)

    {[response], state}
  end

  @impl Raxx.Server
  def handle_info({WWW.Chat, message}, config) do
    event = ServerSentEvent.serialize(%ServerSentEvent{lines: [message], type: "chat"})

    {[Raxx.data(event)], config}
  end
end
