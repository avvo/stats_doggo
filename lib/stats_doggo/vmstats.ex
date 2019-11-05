defmodule StatsDoggo.Vmstats do
  use GenServer

  @moduledoc """
  StatsDoggo.Vmstats is a GenServer that periodically records BEAM virtual machine statistics to
  StatsD.

  Copied and modified based on https://github.com/fanduel/ex_vmstats

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  """

  @timer_msg :interval_elapsed

  defmodule State do
    @moduledoc false

    defstruct [
      :use_histogram,
      :interval,
      :sched_time,
      :prev_sched,
      :timer_ref,
      :namespace,
      :prev_io,
      :prev_gc
    ]

    def new(conf \\ []) do
      interval = interval = kword_or_app(conf, :interval, 3000)

      %__MODULE__{
        interval: interval,
        namespace: kword_or_app(conf, :namespace, "vm_stats"),
        use_histogram: kword_or_app(conf, :use_histogram, false),
        sched_time: sched_time(kword_or_app(conf, :sched_time, false)),
        prev_sched: prev_sched(),
        timer_ref: StatsDoggo.Vmstats.start_timer(interval),
        prev_io: prev_io(),
        prev_gc: :erlang.statistics(:garbage_collection)
      }
    end

    defp prev_io do
      {{:input, input}, {:output, output}} = :erlang.statistics(:io)
      {input, output}
    end

    defp prev_sched do
      :scheduler_wall_time
      |> :erlang.statistics()
      |> Enum.sort()
    end

    defp sched_time(enabled) do
      case {sched_time_available?(), enabled} do
        {true, true} -> :enabled
        {true, _} -> :disabled
        {false, _} -> :unavailable
      end
    end

    defp kword_or_app(conf, key, default) do
      Application.get_env(:ex_vmstats, key, Keyword.get(conf, key, default))
    end

    defp sched_time_available? do
      try do
        :erlang.system_flag(:scheduler_wall_time, true)
      else
        _ -> true
      rescue
        ArgumentError -> false
      catch
        _ -> true
      end
    end
  end

  def start_link(conf \\ []) do
    GenServer.start_link(__MODULE__, conf)
  end

  def init(conf) do
    {:ok, State.new(conf)}
  end

  def handle_info({:timeout, _timer_ref, @timer_msg}, state) do
    %State{interval: interval, namespace: namespace} = state

    metric_name = fn name -> metric(namespace, name) end
    memory_metric_name = fn name -> memory_metric(namespace, name) end

    # Processes
    gauge_or_hist(state, :erlang.system_info(:process_count), metric_name.("proc_count"))
    gauge_or_hist(state, :erlang.system_info(:process_limit), metric_name.("proc_limit"))

    # Messages in queues
    total_messages =
      Enum.reduce(Process.list(), 0, fn pid, acc ->
        case Process.info(pid, :message_queue_len) do
          {:message_queue_len, count} -> count + acc
          _ -> acc
        end
      end)

    gauge_or_hist(state, total_messages, metric_name.("messages_in_queues"))

    # Modules loaded
    gauge_or_hist(state, length(:code.all_loaded()), metric_name.("modules"))

    # Queued up processes (lower is better)
    gauge_or_hist(state, :erlang.statistics(:run_queue), metric_name.("run_queue"))

    # Error logger backlog (lower is better)
    error_logger_backlog =
      case Process.whereis(:error_logger) do
        nil ->
          Process.whereis(Logger)
          |> Process.info(:messages)
          |> elem(1)
          |> Enum.count(fn
            {:notify, {:error, _, _}} ->
              true

            _ ->
              false
          end)

        # Application is using legacy error_logger (pre OTP21)
        error_logger ->
          error_logger
          |> Process.info(:message_queue_len)
          |> elem(1)
      end

    gauge_or_hist(state, error_logger_backlog, metric_name.("error_logger_queue_len"))

    # Memory usage. There are more options available, but not all were kept.
    # Memory usage is in bytes.
    mem = :erlang.memory()

    for metric <- [:total, :processes_used, :atom_used, :binary, :ets] do
      gauge_or_hist(state, Keyword.get(mem, metric), memory_metric_name.(metric))
    end

    # Incremental values
    %State{prev_io: {old_input, old_output}, prev_gc: {old_gcs, old_words, _}} = state

    {{:input, input}, {:output, output}} = :erlang.statistics(:io)

    gc = {gcs, words, _} = :erlang.statistics(:garbage_collection)

    StatsDoggo.increment(metric_name.("io.bytes_in"), input - old_input)
    StatsDoggo.increment(metric_name.("io.bytes_out"), output - old_output)
    StatsDoggo.increment(metric_name.("gc.count"), gcs - old_gcs)
    StatsDoggo.increment(metric_name.("gc.words_reclaimed"), words - old_words)

    # Reductions across the VM, excluding current time slice, already incremental
    {_, reds} = :erlang.statistics(:reductions)

    StatsDoggo.increment(metric_name.("reductions"), reds)

    # Scheduler wall time
    sched =
      case state.sched_time do
        :enabled ->
          new_sched = Enum.sort(:erlang.statistics(:scheduler_wall_time))

          for {sid, active, total} <- wall_time_diff(state.prev_sched, new_sched) do
            scheduler_metric_base = "#{namespace}.scheduler_wall_time.#{sid}"

            StatsDoggo.timing(scheduler_metric_base <> ".active", active)
            StatsDoggo.timing(scheduler_metric_base <> ".total", total)
          end

          new_sched

        _ ->
          nil
      end

    timer_ref = start_timer(interval)

    {:noreply,
     %{state | timer_ref: timer_ref, prev_sched: sched, prev_io: {input, output}, prev_gc: gc}}
  end

  def start_timer(interval) do
    :erlang.start_timer(interval, self(), @timer_msg)
  end

  defp metric(namespace, metric) do
    "#{namespace}.#{metric}"
  end

  defp memory_metric(namespace, metric) do
    "#{namespace}.memory.#{metric}"
  end

  defp gauge_or_hist(%State{use_histogram: true}, value, metric) do
    StatsDoggo.histogram(metric, value)
  end

  defp gauge_or_hist(_, value, metric), do: StatsDoggo.gauge(metric, value)

  defp wall_time_diff(prev_sched, new_sched) do
    for {{i, prev_active, prev_total}, {i, new_active, new_total}} <-
          Enum.zip(prev_sched, new_sched) do
      {i, new_active - prev_active, new_total - prev_total}
    end
  end
end
