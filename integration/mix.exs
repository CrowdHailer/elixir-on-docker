defmodule Integration.MixProject do
  use Mix.Project

  def project do
    [
      app: :integration,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:server_sent_event, "~> 0.2.0"},
      {:httpoison, "~> 0.13.0"},
    ]
  end
end
