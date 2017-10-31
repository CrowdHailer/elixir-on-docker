defmodule WWW.Chat do
  @group :chat

  def publish(message) do
    for client <- :pg2.get_members(@group) do
      send(client, {WWW.Chat, message})
    end

    {:ok, message}
  end

  def join() do
    :ok = :pg2.create(@group)
    :ok = :pg2.join(@group, self())
    {:ok, @group}
  end
end
