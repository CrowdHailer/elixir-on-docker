defmodule WWW.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    env = WWW.Env.read()
    {:ok, secure_port} = env.secure_port

    IO.inspect("---------------")
    IO.inspect(Node.get_cookie)

    options = [port: secure_port, certfile: "/run/secrets/certfile", keyfile: "/run/secrets/keyfile"]

    children = [
      # worker(WWW, [[port: port()]], id: :http),
      # worker(WWW, [[port: secure_port(), tls: tls_options]], id: :https),
      supervisor(Ace.HTTP.Service, [{WWW, :config}, options]),
    ]

    opts = [strategy: :one_for_one, name: WaterCooler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
