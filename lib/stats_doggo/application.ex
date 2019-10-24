defmodule StatsDoggo.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    namespace = Application.fetch_env!(:stats_doggo, :app_name)
    backend = StatsDoggo.VmStatsAdapter

    children = [
      worker(StatsDoggo.Worker, []),
      worker(StatsDoggo.Vmstats, [[namespace: namespace, backend: backend, use_histogram: false]])
    ]

    opts = [strategy: :one_for_one, name: StatsDoggo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
