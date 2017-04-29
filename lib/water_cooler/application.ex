defmodule WaterCooler.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Ace.HTTP, [{WaterCooler.WWW, []}, [port: 8080, name: WaterCooler.WWW]]),
    #   worker(Ace.HTTPS, [{WaterCooler.WWW, :config}, [
    #     port: 8443,
    #     certificate: Application.app_dir(:water_cooler, "priv/localhost.crt"),
    #     certificate_key: Application.app_dir(:water_cooler, "priv/localhost.key")
    #   ]])
    ]

    opts = [strategy: :one_for_one, name: WaterCooler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
