defmodule WaterCooler.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    env = WaterCooler.WWW.Env.read()
    {:ok, secure_port} = env.secure_port
    {:ok, service_name} = env.service_name

    options = [port: secure_port, certfile: certificate_path, keyfile: certificate_key_path()]

    children = [
      # worker(WaterCooler.WWW, [[port: port()]], id: :http),
      # worker(WaterCooler.WWW, [[port: secure_port(), tls: tls_options]], id: :https),
      supervisor(Ace.HTTP.Service, [{WaterCooler.WWW, :config}, options]),
      worker(WaterCooler.DNSDiscovery, [service_name, options])
    ]

    opts = [strategy: :one_for_one, name: WaterCooler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp certificate_path() do
    Application.app_dir(:water_cooler, "priv/localhost/certificate.pem")
  end

  defp certificate_key_path() do
    Application.app_dir(:water_cooler, "priv/localhost/certificate_key.pem")
  end
end
