defmodule WaterCooler.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    certificate_path =
      Application.app_dir(:water_cooler, "priv/localhost/certificate.pem")
    certificate_key_path =
      Application.app_dir(:water_cooler, "priv/localhost/certificate_key.pem")

    tls_options = [certificate: certificate_path, certificate_key: certificate_key_path]

    children = [
      worker(WaterCooler.WWW, [[port: 8080]], id: :http),
      worker(WaterCooler.WWW, [[port: 8443, tls: tls_options]], id: :https)
    ]

    opts = [strategy: :one_for_one, name: WaterCooler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
