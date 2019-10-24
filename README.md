# StatsDoggo

* Uses Statix to send metrics to a StatsD host
* Uses ex_vmstats to gather VM metrics
* Provides a Plug to get web stats

## Installation

```elixir
def deps do
  [
    {:stats_doggo, "~> 1.0.0",
  ]
end
```

Configuration in your `config.exs`

```
config :stats_doggo,
  app_name: "YOUR_APP_NAME",
  override_statix_host: System.fetch_env!("STATSD_HOST"),
  app_env: System.get_env("RAILS_ENV", "dev"),
  enabled: System.get_env("STATS_ENABLED", "false"),
  impl: StatsDoggo.Connection
```

Add to your `endpoint.ex` if you want the plug:
```
  plug StatsDoggo.Plug
```
