defmodule WWW.Mixfile do
  use Mix.Project

  def project do
    [
      app: :www,
      version: "0.0.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {WWW.Application, []}]
  end

  defp deps do
    [
      {:ace, "~> 0.15.2"},
      {:raxx_static, "~> 0.5.0"},
      {:raxx_api_blueprint, "~> 0.1.0"},
      {:exsync, "~> 0.2.1"},
      {:wobserver, "~> 0.1.8"}
    ]
  end
end
