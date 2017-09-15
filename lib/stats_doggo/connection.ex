defmodule StatsDoggo.Connection do
  @moduledoc """
  StatsDoggo.Connection uses Statix to send metrics to a StatsD server.
  """

  use Statix, runtime_config: true

  def init do
    unless connected?() do
      connect()
    end
    :ok
  end

  def connected? do
    case Process.whereis(StatsDoggo.Connection) do
      nil ->
        false
      _ ->
        true
    end
  end
end
