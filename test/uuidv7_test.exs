defmodule UUIDv7Test do
  use ExUnit.Case, async: true

  doctest UUIDv7

  test "generates uuid string" do
    assert <<_::288>> = UUIDv7.generate()
  end

  test "generates uuid binary" do
    assert <<_::128>> = UUIDv7.bingenerate()
  end

  test "encode/1" do
    assert uuid = UUIDv7.bingenerate()
    assert encoded = UUIDv7.encode(uuid)
    assert ^uuid = UUIDv7.decode(encoded)
  end

  test "decode/1" do
    assert uuid = UUIDv7.generate()
    assert decoded = UUIDv7.decode(uuid)
    assert ^uuid = UUIDv7.encode(decoded)
  end
end
