defmodule UUIDv7.TimeLeapTest do
  use ExUnit.Case, async: false

  alias UUIDv7.Clock

  test "next/1 protects against time leaping backwards" do
    <<rand_a::17, _::7>> = :crypto.strong_rand_bytes(3)
    {time1, _clock} = Clock.next(<<rand_a::17>>)

    :timer.sleep(1)

    <<rand_a::17, _::7>> = :crypto.strong_rand_bytes(3)
    {time2, _clock} = Clock.next(<<rand_a::17>>)

    :timer.sleep(1)

    future_timestamp =
      DateTime.utc_now()
      |> DateTime.add(1, :hour)
      |> DateTime.to_unix(:millisecond)

    :persistent_term.get(:timestamp_ref) |> :atomics.put(1, future_timestamp)

    <<rand_a::17, _::7>> = :crypto.strong_rand_bytes(3)
    {time3, _clock} = Clock.next(<<rand_a::17>>)

    assert time1 < time2
    assert time2 < time3
    assert time3 == future_timestamp
  end
end
