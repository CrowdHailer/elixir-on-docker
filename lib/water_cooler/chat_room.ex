defmodule WaterCooler.ChatRoom do
  @default_room :chat

  def publish(message, room \\ @default_room) do
    :gproc.send({:p, :l, room}, {:message, message})
    {:ok, message}
  end

  def join(room \\ @default_room) do
    :gproc.reg({:p, :l, room})
    {:ok, room}
  end
end
