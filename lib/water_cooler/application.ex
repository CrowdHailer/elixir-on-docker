defmodule WaterCooler.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    tls_options = [
      certificate: certificate_path(),
      certificate_key: certificate_key_path()
    ]

    options = [port: secure_port(), certfile: certificate_path, keyfile: certificate_key_path()]

    children = [
      # worker(WaterCooler.WWW, [[port: port()]], id: :http),
      # worker(WaterCooler.WWW, [[port: secure_port(), tls: tls_options]], id: :https),
      supervisor(Ace.HTTP2.Service, [{WaterCooler.WWW, :config}, options]),
      worker(WaterCooler.DNSDiscovery, [System.get_env("SERVICE_NAME"), options])
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

  defp port do
    Application.get_env(:water_cooler, :port)
    |> get_value()
  end

  defp secure_port do
    {p, ""} = System.get_env("SECURE_PORT") |> Integer.parse
    p
  end

  defp get_value({:system, type, env_name, default}) do
    if raw = System.get_env(env_name) do
      cast(type, raw)
    else
      default
    end
  end

  defp cast(:port, raw) do
    {port, ""} = Integer.parse(raw)
    port
  end
end
