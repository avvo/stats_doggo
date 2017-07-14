defmodule StatsDoggo.VmStatsAdapter do
  @doc """
  https://github.com/fanduel/ex_vmstats

  Adapter to switch (value, metric) to (metric, value)
  """

  def timer(value, metric), do: StatsDoggo.timing(metric, value)
  def counter(value, metric), do: StatsDoggo.increment(metric, value)
  def gauge(value, metric), do: StatsDoggo.gauge(metric, value)
  def histogram(value, metric), do: StatsDoggo.histogram(metric, value)
end
