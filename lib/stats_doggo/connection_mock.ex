defmodule StatsDoggo.ConnectionMock do
  @moduledoc """
  StatsDoggo.ConnectionMock purposefully does nothing. Useful for test or dev where you don't care
  about the metrics.
  """

  def init(), do: :ok
  def connected?(), do: true
  def decrement(_name, _value \\ 1, _opts \\ []), do: :ok
  def gauge(_name, _value, _opts \\ []), do: :ok
  def increment(_name, _value \\ 1, _opts \\ []), do: :ok
  def set(_name, _value, _opts \\ []), do: :ok
  def timing(_name, _value, _opts \\ []), do: :ok
  def histogram(_name, _value, _opts \\ []), do: :ok
end
