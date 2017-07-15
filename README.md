# StatsDoggo

* Uses Statix to send metrics to a StatsD host
* Uses ex_vmstats to gather VM metrics
* Provides a Plug to get web stats

## Installation

```elixir
def deps do
  [
    {:stats_doggo, github: "avvo/stats_doggo"},
  ]
end
```

Configuration in your `config.exs`

```
config :stats_doggo,
  app_name: "YOUR_APP_NAME",
  override_statix_host: {:system, "STATSD_HOST"},
  app_env: {:system, "RAILS_ENV", "dev"},
  enabled: {:system, "STATS_ENABLED", "false"},
  impl: StatsDoggo.Connection
```

Add to your `endpoint.ex` if you want the plug:
```
  plug StatsDoggo.Plug
```
