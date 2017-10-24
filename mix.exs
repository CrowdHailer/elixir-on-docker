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
      {:ace, "~> 0.15.0"},
      {:tokumei, path: "../tokumei"},
      {:server_sent_event, "~> 0.2.0"},
      {:exsync, "~> 0.2.0"},
      {:wobserver, "~> 0.1.8"},
    ]
  end
end
