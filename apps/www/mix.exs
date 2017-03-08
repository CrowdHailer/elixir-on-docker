defmodule WaterCooler.WWW.Mixfile do
  use Mix.Project

  def project do
    [app: :www,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :gproc],
     mod: {WaterCooler.WWW, []}]
  end

  defp deps do
    [
      {:tokumei, path: "../../../app"},
      {:ace_http, "~> 0.1.3"},
      {:gproc, "0.3.1"},
    ]
  end
end
