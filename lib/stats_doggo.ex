defmodule StatsDoggo do
  def decrement(name, value \\ 1, opts \\ []) do
    GenServer.cast(StatsDoggo.Worker, {:decrement, [name, value, opts]})
  end

  def gauge(name, value, opts \\ []) do
    GenServer.cast(StatsDoggo.Worker, {:gauge, [name, value, opts]})
  end

  def increment(name, value \\ 1, opts \\ []) do
    GenServer.cast(StatsDoggo.Worker, {:increment, [name, value, opts]})
  end

  def set(name, value, opts \\ []) do
    GenServer.cast(StatsDoggo.Worker, {:set, [name, value, opts]})
  end

  def timing(name, value, opts \\ []) do
    GenServer.cast(StatsDoggo.Worker, {:timing, [name, value, opts]})
  end

  def histogram(name, value, opts \\ []) do
    GenServer.cast(StatsDoggo.Worker, {:histogram, [name, value, opts]})
  end
end
