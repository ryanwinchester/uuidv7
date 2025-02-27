defmodule UUIDv7.TimeLeapTest do
  use ExUnit.Case, async: false

  alias UUIDv7.Clock

  test "next/1 protects against time leaping backwards" do
    atomic_timer_ref = :persistent_term.get(Clock)

    time1 = Clock.next_ascending()

    :timer.sleep(1)

    time2 = Clock.next_ascending()

    :timer.sleep(1)

    future_timestamp =
      DateTime.utc_now()
      |> DateTime.add(1, :hour)
      |> DateTime.to_unix(:nanosecond)

    :atomics.put(atomic_timer_ref, 1, future_timestamp)

    time3 = Clock.next_ascending()

    assert time1 < time2
    assert time2 < time3
    assert time3 > future_timestamp
  end
end
