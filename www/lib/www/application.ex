defmodule WWW.Application do
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    env = WWW.Env.read()

    Logger.info("`#{__MODULE__}` started on node `#{Node.self()}`")
    {:ok, peer_list} = env.peer_list

    Logger.info("Connecting to peers: `[#{Enum.join(peer_list, ", ")}]`")
    Enum.each(peer_list, &Node.connect/1)
    Logger.info("Connected peers: `[#{Enum.join(Node.list(), ", ")}]`")

    cleartext_options = [port: 8080, cleartext: true]
    secure_options = [port: 8443, certfile: certificate_path(), keyfile: certificate_key_path()]

    children = [
      supervisor(Ace.HTTP.Service, [{WWW, :config}, cleartext_options], id: :www_cleartext),
      supervisor(Ace.HTTP.Service, [{WWW, :config}, secure_options], id: :www_secure)
    ]

    opts = [strategy: :one_for_one, name: WWW.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp certificate_path() do
    Application.app_dir(:www, "priv/localhost/certificate.pem")
  end

  defp certificate_key_path() do
    Application.app_dir(:www, "priv/localhost/certificate_key.pem")
  end
end
