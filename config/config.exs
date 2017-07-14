use Mix.Config

config :stats_doggo,
  app_name: "stats_doggo",
  override_statix_host: {:system, "STATSD_HOST"},
  app_env: {:system, "RAILS_ENV", "dev"},
  enabled: {:system, "STATS_ENABLED", "false"},
  impl: StatsDoggo.Connection

config :ex_vmstats,
  namespace: "stats_doggo",
  backend: StatsDoggo.VmStatsAdapter,
  interval: 3000,
  use_histogram: true,
  sched_time: false
