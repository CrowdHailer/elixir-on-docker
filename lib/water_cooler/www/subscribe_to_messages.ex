defmodule WaterCooler.WWW.SubscribeToMessages do
  use Raxx.Server

  alias WaterCooler.ChatRoom
  require ChatRoom

  @impl Raxx.Server
  def handle_request(_request, state) do
    {:ok, _} = ChatRoom.join()

    {
      [
        Raxx.response(:ok)
        |> Raxx.set_header("content-type", "text/event-stream")
        |> Raxx.set_body(true)
      ],
      state
    }
  end

  @impl Raxx.Server
  def handle_info(ChatRoom.post(data), config) do
    data = ServerSentEvent.serialize(%ServerSentEvent{lines: [data], type: "chat"})
    fragment = Raxx.data(data)
    {[fragment], config}
  end
end
