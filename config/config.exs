use Mix.Config

config :stats_doggo,
  app_name: "stats_doggo",
  override_statix_host: {:system, "STATSD_HOST"},
  app_env: {:system, "RAILS_ENV", "dev"},
  enabled: {:system, "STATS_ENABLED", "false"},
  impl: StatsDoggo.Connection

if File.regular?("config/#{Mix.env}.exs") do
  import_config "#{Mix.env}.exs"
end
