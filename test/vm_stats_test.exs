defmodule VmStatsTest do
  use ExUnit.Case, async: true

  setup do
    stats_server_pid = start_supervised!(StatsDoggo.Vmstats)
    %{stats_server_pid: stats_server_pid}
  end

  test "does not crash on pre-otp21 error queue length", %{stats_server_pid: stats_server_pid} do
    :error_logger.add_report_handler(:error_handler)

    send(stats_server_pid, {:timeout, "ref", :interval_elapsed})
  end

  test "does not crash on OTP21 logger error message queue length", %{stats_server_pid: stats_server_pid} do
    send(stats_server_pid, {:timeout, "ref", :interval_elapsed})
  end
end
