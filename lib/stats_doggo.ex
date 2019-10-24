defmodule StatsDoggo do
  @moduledoc """
  StatsDoggo provides an interface to StatsD that can be swapped out for different implementations
  for testing and development.
  """

  @type key_t :: String.t()
  @type value_t :: integer | float
  @type options_t :: [sample_rate: float, tags: [String.t()]]
  @type on_send_t :: :ok

  @doc """
  Same as `decrement(key, 1)`
  """
  @spec decrement(key_t) :: on_send_t
  def decrement(key), do: decrement(key, 1)

  @doc """
  Same as `decrement(key, value, [])`
  """
  @spec decrement(key_t, integer) :: on_send_t
  def decrement(key, value), do: decrement(key, value, [])

  @doc """
  Decrement a counter.

  Will always return :ok regardless of the state of the StatsDoggo.Worker.

  ## Examples

      # Decrement by 1
      iex> StatsDoggo.decrement("myapp.foo")
      :ok

      # Decrement by 5
      iex> StatsDoggo.decrement("myapp.bar", 5)
      :ok

      # Decrement with tags
      iex> StatsDoggo.decrement("myapp.bar", 1, tags: "env:prod")
      :ok
  """
  @spec decrement(key_t, value_t, options_t) :: on_send_t
  def decrement(key, value, opts) when is_binary(key) and is_integer(value) and is_list(opts) do
    GenServer.cast(StatsDoggo.Worker, {:decrement, [key, value, opts]})
  end

  @doc """
  Same as `gauge(key, value, [])`

  ## Examples

      iex> StatsDoggo.gauge("cpu_usage", 0.83)
      :ok
  """
  @spec gauge(key_t, value_t) :: on_send_t
  def gauge(key, value), do: gauge(key, value, [])

  @doc """
  Writes to the StatsD gauge identified by `key`.

  Will always return :ok regardless of the state of the StatsDoggo.Worker.

  ## Examples

      iex> StatsDoggo.gauge("cpu_usage", 0.83, tags: "env:prod")
      :ok
  """
  @spec gauge(key_t, value_t, options_t) :: on_send_t
  def gauge(key, value, opts)
      when is_binary(key) and (is_float(value) or is_integer(value)) and is_list(opts) do
    GenServer.cast(StatsDoggo.Worker, {:gauge, [key, value, opts]})
  end

  @doc """
  Same as `increment(key, 1)`
  """
  @spec increment(key_t) :: on_send_t
  def increment(key), do: increment(key, 1)

  @doc """
  Same as `increment(key, value, [])`
  """
  @spec increment(key_t, integer) :: on_send_t
  def increment(key, value), do: increment(key, value, [])

  @doc """
  Increment a counter.

  Will always return :ok regardless of the state of the StatsDoggo.Worker.

  ## Examples

      # Increment by 1
      iex> StatsDoggo.increment("myapp.foo")
      :ok

      # Increment by 5
      iex> StatsDoggo.increment("myapp.bar", 5)
      :ok

      # Increment with tags
      iex> StatsDoggo.increment("myapp.bar", 1, tags: "env:prod")
      :ok
  """
  @spec increment(key_t, integer, options_t) :: on_send_t
  def increment(key, value, opts) when is_binary(key) and is_integer(value) and is_list(opts) do
    GenServer.cast(StatsDoggo.Worker, {:increment, [key, value, opts]})
  end

  @doc """
  Same as `set(key, value, [])`
  """
  @spec set(key_t, String.t()) :: on_send_t
  def set(key, value), do: set(key, value, [])

  @doc """
  Writes the given `value` to the StatsD set identified by `key`.

  ## Examples
      iex> StatsDoggo.set("unique_visitors", "user1", [])
      :ok
  """
  @spec set(key_t, String.t(), options_t) :: on_send_t
  def set(key, value, opts) when is_binary(key) and is_binary(value) and is_list(opts) do
    GenServer.cast(StatsDoggo.Worker, {:set, [key, value, opts]})
  end

  @doc """
  Same as `timing(key, value, [])`
  """
  @spec timing(key_t, value_t) :: on_send_t
  def timing(key, value), do: timing(key, value, [])

  @doc """
  Writes the given `value` to the StatsD timing identified by `key`.

  `value` is expected in milliseconds.

  ## Examples
      iex> StatsDoggo.timing("rendering", 12, [])
      :ok
  """
  @spec timing(key_t, value_t, options_t) :: on_send_t
  def timing(key, value, opts)
      when is_binary(key) and (is_integer(value) or is_float(value)) and is_list(opts) do
    GenServer.cast(StatsDoggo.Worker, {:timing, [key, value, opts]})
  end

  @doc """
  Same as `histogram(key, value, [])`
  """
  @spec histogram(key_t, value_t) :: on_send_t
  def histogram(key, value), do: histogram(key, value, [])

  @doc """
  Writes `value` to the histogram identified by `key`.

  ## Examples

      iex> StatsDoggo.histogram("online_users", 123, [])
      :ok
  """
  @spec histogram(key_t, value_t, options_t) :: on_send_t
  def histogram(key, value, opts)
      when is_binary(key) and (is_integer(value) or is_float(value)) and is_list(opts) do
    GenServer.cast(StatsDoggo.Worker, {:histogram, [key, value, opts]})
  end
end
