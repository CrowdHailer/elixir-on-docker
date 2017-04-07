defmodule WaterCooler.Mixfile do
  use Mix.Project

  def project do
    [app: :water_cooler,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :gproc],
     mod: {WaterCooler, []}]
  end

  defp deps do
    [
      {:tokumei, path: "../app"},
      {:ace_http, "~> 0.1.3"},
      {:gproc, "0.3.1"}
    ]
  end
end
