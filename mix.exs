defmodule WaterCooler.Mixfile do
  use Mix.Project

  def project do
    [app: :water_cooler,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {WaterCooler.Application, []}]
  end

  defp deps do
    [
      {:tokumei, "~> 0.6.3"},
      {:ace_http, "~> 0.4.0"},
      {:server_sent_event, "~> 0.1.0"},
      {:gproc, "0.3.1"},
      {:mix_docker, "~> 0.4.2"},
      {:exsync, "~> 0.1.4"}
    ]
  end
end
