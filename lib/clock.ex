defmodule UUIDv7.Clock do
  @moduledoc false
  # Add docs later.
  use GenServer

  @type timestamp :: integer()
  @type counter :: <<_::18>>
  @type counter_seed :: <<_::17>>

  @default_cleanup_interval_ms 60 * 1000
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
  def next(<<seed::big-unsigned-17>>) do
    current_ts = System.system_time(:millisecond)

    clock =
      with @threshold <- update_counter(current_ts, seed) do
        update_counter(current_ts + 1, seed)
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
  # Helpers
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

  defp update_counter(ts, seed) do
    :ets.update_counter(__MODULE__, ts, 1, {ts, seed})
  end

  defp schedule_cleanup(interval_ms) do
    Process.send_after(self(), :cleanup, interval_ms)
  end

  defp cleanup(cutoff) do
    timestamp = System.system_time(:millisecond) - cutoff
    :ets.select_delete(__MODULE__, [{{:"$1", :_}, [{:<, :"$1", timestamp}], [true]}])
  end
end
