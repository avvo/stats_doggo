defmodule StatsDoggo do
  require Logger
  use GenServer

  @app_tag "app:#{EnvConfig.get(:stats_doggo, :app_name)}"
  @env_tag "env:#{EnvConfig.get(:stats_doggo, :app_env)}"

  @default_tags [@env_tag, @app_tag]

  def init(:ok) do
    set_up_config()

    connection = case EnvConfig.get(:stats_doggo, :enabled) do
      "false" ->
        Logger.info "StatsDoggo disabled, using StatsDoggo.ConnectionMock"
        StatsDoggo.ConnectionMock
      x ->
        impl = Application.fetch_env!(:stats_doggo, :impl)
        Logger.info "StatsDoggo #{inspect(x)}, using #{inspect(impl)}"
        impl
    end
    connection.init

    {:ok, connection}
  end

  def start(_, _) do
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_cast({command, args}, connection) do
    apply(connection, command, args)
    {:noreply, connection}
  end

  def decrement(name, value \\ 1, opts \\ []) do
    GenServer.cast(__MODULE__, {:decrement, [name, value, opts |> default_opts()]})
  end

  def gauge(name, value, opts \\ []) do
    GenServer.cast(__MODULE__, {:gauge, [name, value, opts |> default_opts()]})
  end

  def increment(name, value \\ 1, opts \\ []) do
    GenServer.cast(__MODULE__, {:increment, [name, value, opts |> default_opts()]})
  end

  def set(name, value, opts \\ []) do
    GenServer.cast(__MODULE__, {:set, [name, value, opts |> default_opts()]})
  end

  def timing(name, value, opts \\ []) do
    GenServer.cast(__MODULE__, {:timing, [name, value, opts |> default_opts()]})
  end

  def histogram(name, value, opts \\ []) do
    GenServer.cast(__MODULE__, {:histogram, [name, value, opts |> default_opts()]})
  end

  defp default_opts(opts) do
    opts |> Keyword.merge(tags: Keyword.get(opts, :tags, []) |> default_tags())
  end

  defp default_tags(tags) do
    @default_tags ++ tags
  end

  defp set_up_config do
    Application.put_env(:statix, :host, EnvConfig.get(:stats_doggo, :override_statix_host))
  end
end
