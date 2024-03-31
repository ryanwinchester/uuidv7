defmodule UUIDv7.OrderedTest do
  use ExUnit.Case, async: true

  test "generate/1 is ordered" do
    uuids =
      for _ <- 1..100 do
        UUIDv7.generate()
        :timer.sleep(1)
      end

    assert uuids == Enum.sort(uuids)
  end

  test "bingenerate/1 is ordered" do
    uuids =
      for _ <- 1..100 do
        UUIDv7.bingenerate()
        :timer.sleep(1)
      end

    assert uuids == Enum.sort(uuids)
  end
end
