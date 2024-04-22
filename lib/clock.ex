defmodule UUIDv7.Clock do
  @moduledoc false
  use GenServer

  @type timestamp :: integer()
  @type counter :: <<_::18>>
  @type counter_seed :: <<_::17>>

  @default_table_opts [:named_table, :public, :set]
  @default_cleanup_interval_ms :timer.seconds(2)
  @default_cleanup_tick_cutoff 2

  # The threshold number where the counter will roll over.
  @max_counter 2 ** 18

  @compile {:inline, [update_counter: 2]}

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
    # by 1 millisecond to preserve order, which will also reset the counter
    # using the provided seed value.
    clock =
      with @max_counter <- update_counter(current_ts, seed) do
        next_ts = current_ts + 1
        :atomics.put(timestamp_ref, 1, next_ts)
        update_counter(next_ts, seed)
      end

    {current_ts, <<clock::big-unsigned-18>>}
  end

  @doc """
  Starts the Clock server.

  The GenServer part of this module is used for managing the ETS table and not
  for generating UUIDs.

  ### Options

   * `:cleanup_interval` - The interval in milliseconds that the table cleanup
     task is run. Defaults to `#{@default_cleanup_interval_ms}`.
   * `:cleanup_tick_cutoff` - The number of timestamp ticks ago that the table
     is pruned to. Defaults to `#{@default_cleanup_tick_cutoff}`.

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    if Keyword.get(opts, :start?, true) do
      name = Keyword.get(opts, :name) || __MODULE__
      GenServer.start_link(__MODULE__, opts, name: name)
    else
      :ignore
    end
  end

  # ----------------------------------------------------------------------------
  # GenServer callbacks.
  # ----------------------------------------------------------------------------

  @impl GenServer
  def init(opts) do
    interval_ms = Keyword.get(opts, :cleanup_interval, @default_cleanup_interval_ms)
    cleanup_tick_cutoff = Keyword.get(opts, :cleanup_tick_cutoff, @default_cleanup_tick_cutoff)
    ets_opts = Keyword.get(opts, :table, @default_table_opts)

    state = %{
      table: :ets.new(__MODULE__, ets_opts),
      interval_ms: interval_ms,
      timestamp_ref: :persistent_term.get(__MODULE__),
      cleanup_tick_cutoff: cleanup_tick_cutoff
    }

    schedule_cleanup(interval_ms)

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    cleanup(state.timestamp_ref, state.cleanup_tick_cutoff)
    schedule_cleanup(state.interval_ms)
    {:noreply, state}
  end

  # ----------------------------------------------------------------------------
  # Manage ETS table.
  # ----------------------------------------------------------------------------

  # The current best solution for having a counter that resets for every
  # millisecond tick is to use the millisecond timestamp as the keys for
  # en `ets` table and use `update_counter`. It avoids having to use a
  # GenServer for state, or have an ever-increasing monotonic integer that
  # doesn't reset and introduces the chance of rollover (which would break sort
  # order every time this occurs).
  defp update_counter(ts, seed) do
    :ets.update_counter(__MODULE__, ts, 1, {ts, seed})
  end

  # NOTE: I still want to benchmark different cutoffs and cleanup intervals.
  defp cleanup(timestamp_ref, cutoff) do
    timestamp = System.system_time(:millisecond)
    previous_ts = :atomics.get(timestamp_ref, 1)

    # If the last timestamp was over 10 seconds ago, then we don't bother to run the cleanup.
    if timestamp - previous_ts < 10_000 do
      # Cleanup all entries that are older than the cutoff.
      :ets.select_delete(__MODULE__, [{{:"$1", :_}, [{:<, :"$1", timestamp - cutoff}], [true]}])
    end
  end

  defp schedule_cleanup(interval_ms) do
    Process.send_after(self(), :cleanup, interval_ms)
  end
end
