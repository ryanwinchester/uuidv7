defmodule UUIDv7.Clock do
  # See the Postgres version (in `C`):
  # https://github.com/postgres/postgres/blob/0e42d31b0b2273c376ce9de946b59d155fac589c/src/backend/utils/adt/uuid.c#L480

  @moduledoc false

  # For macOS (Darwin) or Windows we would normally use 10 bits instead of 12.
  # However, it would be an extra complexity and tradeoff of checking OS at
  # runtime with some extra calcs, just for 2 bits of extra randomness for
  # people running their applications on Windows or macOS.
  @sub_ms_bits 12

  # The count of possible values that fit in those bits (4096 or 2^12).
  @possible_values Bitwise.bsl(1, @sub_ms_bits)

  @ns_per_ms 1_000_000

  @minimal_step_ns div(@ns_per_ms, @possible_values) + 1

  @doc """
  Get an always-ascending unix nanosecond timestamp.

  We use `:atomics` to ensure this works with concurrent executions without race
  conditions.
  """
  def next_ascending do
    # Get the atomic ref for the timestamp and initialize it if it doesn't exist yet.
    timestamp_ref =
      with nil <- :persistent_term.get(__MODULE__, nil) do
        timestamp_ref = :atomics.new(1, signed: false)
        :ok = :persistent_term.put(__MODULE__, timestamp_ref)
        timestamp_ref
      end

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
