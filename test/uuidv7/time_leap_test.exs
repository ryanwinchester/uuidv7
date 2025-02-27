defmodule UUIDv7.TimeLeapTest do
  use ExUnit.Case, async: false

  alias UUIDv7.Clock

  describe "next_ascending/0" do
    test "protects against time leaping (always-ascending)" do
      time1 = Clock.next_ascending()

      time2 = Clock.next_ascending()

      future_timestamp =
        DateTime.utc_now()
        |> DateTime.add(1, :hour)
        |> DateTime.to_unix(:nanosecond)

      :persistent_term.get(Clock) |> :atomics.put(1, future_timestamp)

      time3 = Clock.next_ascending()

      time4 = Clock.next_ascending()

      assert time1 < time2
      assert time2 < time3
      assert time3 > future_timestamp
      assert time3 < time4
    end
  end
end
