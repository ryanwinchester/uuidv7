defmodule UUIDv7.Clock do
  @moduledoc false
  use GenServer

  @type timestamp :: integer()
  @type counter :: <<_::18>>
  @type counter_seed :: <<_::17>>

  @default_cleanup_interval_ms :timer.seconds(2)
  @default_cleanup_tick_cutoff 2

  # The threshold is the number before the counter will roll over.
  # It is `2 ** (number of bits) - 1`.
  @threshold 2 ** 18 - 1

  @compile {:inline, [update_counter: 2]}

  @doc """
  Starts the Clock server.

  ### Options

   * `:cleanup_interval` - The interval in milliseconds that the table cleanup
     task is run. Defaults to `#{@default_cleanup_interval_ms}`.
   * `:cleanup_tick_cutoff` - The number of timestamp ticks ago that the table
     is pruned to. Defaults to `#{@default_cleanup_tick_cutoff}`.

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Get a unix millisecond timestamp and a clock sequence that fits in 18 bits.
  """
  @spec next(counter_seed()) :: {timestamp(), counter()}
  def next(<<seed::17>>) do
    timestamp_ref = :persistent_term.get(__MODULE__)
    previous_ts = :atomics.get(timestamp_ref, 1)
    current_ts = System.system_time(:millisecond)

    # Time leap backwards protection.
    current_ts = if current_ts < previous_ts, do: previous_ts, else: current_ts

    :atomics.put(timestamp_ref, 1, current_ts)

    # Rollover protection.
    # If the counter is over the allotted bits, then we update the timestamp
    # by 1 millisecond instead to preserve order.
    clock =
      with @threshold <- update_counter(current_ts, seed) do
        next_ts = current_ts + 1
        :atomics.put(timestamp_ref, 1, next_ts)
        update_counter(next_ts, seed)
      end

    {current_ts, <<clock::big-unsigned-18>>}
  end

  # ----------------------------------------------------------------------------
  # GenServer callbacks.
  # ----------------------------------------------------------------------------

  @impl GenServer
  def init(opts) do
    interval_ms = Keyword.get(opts, :cleanup_interval, @default_cleanup_interval_ms)
    cleanup_tick_cutoff = Keyword.get(opts, :cleanup_tick_cutoff, @default_cleanup_tick_cutoff)

    state = %{
      table: create_table(),
      interval_ms: interval_ms,
      cleanup_tick_cutoff: cleanup_tick_cutoff
    }

    schedule_cleanup(interval_ms)

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    cleanup(state.cleanup_tick_cutoff)
    schedule_cleanup(state.interval_ms)
    {:noreply, state}
  end

  # ----------------------------------------------------------------------------
  # Private API
  # ----------------------------------------------------------------------------

  defp create_table do
    :ets.new(__MODULE__, [
      :named_table,
      :public,
      :set,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ])
  end

  # The current best solution for having a counter that resets for every
  # millisecond tick is to use the millisecond timestamp as the keys for
  # en `ets` table and use `update_counter`. It avoids having to use a
  # GenServer for state, or have an ever-increasing monotonic integer that
  # doesn't reset and introduces the chance of rollover (which would break sort
  # order every time this occurs). Any better ideas? Submit an issue.
  defp update_counter(ts, seed) do
    :ets.update_counter(__MODULE__, ts, 1, {ts, seed})
  end

  # NOTE: The thing that bothers me the most about this implementation is the
  # cleanup and how it may (possibly?) effect performance. I need to do some
  # benchmarks to test if this effects `:ets.update_counter/4` at all.
  defp cleanup(cutoff) do
    timestamp = System.system_time(:millisecond) - cutoff
    :ets.select_delete(__MODULE__, [{{:"$1", :_}, [{:<, :"$1", timestamp}], [true]}])
  end

  defp schedule_cleanup(interval_ms) do
    Process.send_after(self(), :cleanup, interval_ms)
  end
end
