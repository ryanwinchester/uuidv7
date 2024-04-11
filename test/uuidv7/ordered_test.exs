defmodule UUIDv7.OrderedTest do
  use ExUnit.Case, async: true

  test "generate/1 is ordered" do
    uuids =
      for _ <- 1..10_000 do
        UUIDv7.generate()
      end

    assert uuids == Enum.sort(uuids)
  end

  test "bingenerate/1 is ordered" do
    uuids =
      for _ <- 1..10_000 do
        UUIDv7.bingenerate()
      end

    assert uuids == Enum.sort(uuids)
  end
end
