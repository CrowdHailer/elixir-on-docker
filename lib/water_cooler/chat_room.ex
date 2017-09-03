defmodule WaterCooler.ChatRoom do
  @default_room :chat

  defmacro post(content) do
    quote do
      {unquote(__MODULE__), unquote(content)}
    end
  end

  def publish(message, room \\ @default_room) do
    for client <- :pg2.get_members(room) do
      send(client, {WaterCooler.ChatRoom, message})
    end
    {:ok, message}
  end

  def join(room \\ @default_room) do
    :ok = :pg2.create(room)
    :ok = :pg2.join(room, self())
    {:ok, room}
  end
end
