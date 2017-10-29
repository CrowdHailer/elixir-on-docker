defmodule WWW.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    env = WWW.Env.read()
    {:ok, secure_port} = env.secure_port

    IO.inspect("---------------")
    IO.inspect(Node.self)
    IO.inspect(Node.get_cookie)
    Node.connect(:"app@www-1")
    Node.connect(:"app@www-2")
    Node.connect(:"app@www-3")
    IO.inspect(Node.list)

    options = [port: secure_port, certfile: "/run/secrets/certfile", keyfile: "/run/secrets/keyfile"]

    children = [
      supervisor(Ace.HTTP.Service, [{WWW, :config}, [port: 8080, cleartext: true]], id: :www_cleartext),
      supervisor(Ace.HTTP.Service, [{WWW, :config}, options], id: :www_secure),
    ]

    opts = [strategy: :one_for_one, name: WaterCooler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
