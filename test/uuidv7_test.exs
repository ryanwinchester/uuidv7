defmodule UUIDv7Test do
  use ExUnit.Case, async: true

  doctest UUIDv7, except: [:moduledoc, generate: 0, generate: 1, bingenerate: 0, bingenerate: 1]

  test "generate/0 generates uuid string" do
    assert <<_::288>> = UUIDv7.generate()
  end

  test "generate/1 generates uuid string" do
    assert <<_::288>> = UUIDv7.generate(DateTime.utc_now())
  end

  test "bingenerate/0 generates uuid binary" do
    assert <<_::128>> = UUIDv7.bingenerate()
  end

  test "bingenerate/1 generates uuid binary" do
    assert <<_::128>> = UUIDv7.bingenerate(DateTime.utc_now())
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

  test "get_timestamp/1 gets the original timestamp" do
    assert timestamp = 1_711_827_060_456_999
    assert uuid = UUIDv7.bingenerate(timestamp) |> UUIDv7.encode()
    assert UUIDv7.get_timestamp(uuid) == timestamp
  end
end
