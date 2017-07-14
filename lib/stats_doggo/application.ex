defmodule StatsDoggo.Application do
  @moduledoc false

  use Application

  @config_defaults [
    namespace: Application.fetch_env!(:stats_doggo, :app_name),
    backend: StatsDoggo.VmStatsAdapter,
    interval: 3000,
    use_histogram: true,
    sched_time: false,
  ]

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Enum.each(@config_defaults, fn {key, default} ->
      value = Application.get_env(:stats_doggo, :"vmstats_#{key}", default)
      Application.put_env(:ex_vmstats, key, value)
    end)

    children = [
      worker(StatsDoggo.Worker, []),
      worker(ExVmstats, []),
    ]

    opts = [strategy: :one_for_one, name: StatsDoggo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
