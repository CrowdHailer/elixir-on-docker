defmodule WaterCooler.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    certificate_path =
      Application.app_dir(:water_cooler, "priv/localhost/certificate.pem")
    certificate_key_path =
      Application.app_dir(:water_cooler, "priv/localhost/certificate_key.pem")

    app = {WaterCooler.WWW, []}

    children = [
      worker(Ace.HTTP, [app, [
        port: 8080,
        name: WaterCooler.WWW
      ]]),
      worker(Ace.HTTPS, [app, [
        port: 8443,
        certificate: certificate_path,
        certificate_key: certificate_key_path
      ]])
    ]

    opts = [strategy: :one_for_one, name: WaterCooler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
