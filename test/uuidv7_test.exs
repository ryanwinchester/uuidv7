defmodule UUIDv7Test do
  use ExUnit.Case

  doctest UUIDv7

  test "generates uuid string" do
    assert <<_::288>> = UUIDv7.generate()
  end

  test "generates uuid binary" do
    assert <<_::128>> = UUIDv7.bingenerate()
  end
end
