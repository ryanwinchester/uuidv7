defmodule UUIDv7.Clock do
  @moduledoc false

  # For macOS (Darwin) or Windows use 10 bits.
  # Otherwise, use 12 bits (e.g. on Linux).
  step_bits =
    case :os.type() do
      {:unix, :darwin} -> 10
      {:win32, _} -> 10
      {_, _} -> 12
    end

  ns_per_ms = 1_000_000

  @minimal_step_ns div(ns_per_ms, Bitwise.bsl(1, step_bits)) + 1

  @doc """
  Get an always-ascending unix nanosecond timestamp.

  This is a re-implementation of the Postgres version here (in `C`):
  https://github.com/postgres/postgres/blob/0e42d31b0b2273c376ce9de946b59d155fac589c/src/backend/utils/adt/uuid.c#L480

  We use `:atomics` to ensure this works with concurrent executions without race
  conditions.
  """
  def next_ascending do
    # Get the atomics ref that we set in `UUIDv7.Application.start/2`.
    timestamp_ref = :persistent_term.get(__MODULE__)

    previous_ts = :atomics.get(timestamp_ref, 1)
    min_step_ts = previous_ts + @minimal_step_ns
    current_ts = System.system_time(:nanosecond)

    # If the current timestamp is not at least the minimal step nanoseconds
    # greater than the previous step, then we make it so.
    new_ts =
      if current_ts > min_step_ts do
        current_ts
      else
        min_step_ts
      end

    compare_exchange(timestamp_ref, previous_ts, new_ts)
  end

  defp compare_exchange(timestamp_ref, previous_ts, new_ts) do
    case :atomics.compare_exchange(timestamp_ref, 1, previous_ts, new_ts) do
      # If the new value was written, then we return it.
      :ok ->
        new_ts

      # If the atomic value has changed in the meantime, we add the minimal step
      # nanoseconds value to that and try again.
      updated_ts ->
        compare_exchange(timestamp_ref, updated_ts, updated_ts + @minimal_step_ns)
    end
  end
end
