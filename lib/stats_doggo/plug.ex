defmodule StatsDoggo.Plug do
  @moduledoc """
  StatsDoggo.Plug times each request and records the timing to StatsDoggo as
  [app_name].web.response_time.
  """

  @behaviour Plug
  import Plug.Conn, only: [register_before_send: 2]

  @app_name Application.get_env(:stats_doggo, :app_name)
  @timing_key "#{@app_name}.web.response_time"

  def init(opts), do: opts

  def call(conn, _config) do
    before_time = :os.timestamp()

    register_before_send(conn, fn conn ->
      after_time = :os.timestamp()
      diff = :timer.now_diff(after_time, before_time)

      StatsDoggo.timing(@timing_key, diff / 1_000)
      conn
    end)
  end
end
