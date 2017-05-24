use Mix.Config

config :water_cooler,
  port: {:system, :port, "PORT", 8080},
  secure_port: {:system, :port, "SECURE_PORT", 8443}
