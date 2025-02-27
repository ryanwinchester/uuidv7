defmodule UUIDv7.TimeLeapTest do
  use ExUnit.Case,
    async: false,
    parameterize: [
      %{sub_ms_bits: 10},
      %{sub_ms_bits: 12}
    ]

  alias UUIDv7.Clock

  test "next/1 protects against time leaping backwards", %{sub_ms_bits: sub_ms_bits} do
    atomic_timer_ref = :persistent_term.get(Clock)

    time1 = Clock.next_ascending(sub_ms_bits)

    :timer.sleep(1)

    time2 = Clock.next_ascending(sub_ms_bits)

    :timer.sleep(1)

    future_timestamp =
      DateTime.utc_now()
      |> DateTime.add(1, :hour)
      |> DateTime.to_unix(:nanosecond)

    :atomics.put(atomic_timer_ref, 1, future_timestamp)

    time3 = Clock.next_ascending(sub_ms_bits)

    assert time1 < time2
    assert time2 < time3
    assert time3 > future_timestamp
  end
end
