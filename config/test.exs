use Mix.Config

config :logger, level: :warn

config :stats_doggo,
  app_name: "stats_doggo",
  app_env: "dev",
  enabled: "false",
  impl: StatsDoggo.Connection
