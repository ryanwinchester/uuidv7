defmodule UUIDv7Test do
  use ExUnit.Case, async: true

  doctest UUIDv7, except: [:moduledoc, generate: 0, generate: 1, bingenerate: 0, bingenerate: 1]

  test "generate/0 generates uuid string" do
    assert <<_::288>> = UUIDv7.generate()
  end

  test "bingenerate/0 generates uuid binary" do
    assert <<_::48, 7::4, _::12, 2::2, _::62>> = UUIDv7.bingenerate()
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

  test "extract_timestamp/1 gets a timestamp" do
    assert uuid = UUIDv7.bingenerate() |> UUIDv7.encode()
    assert timestamp = UUIDv7.extract_timestamp(uuid)
    assert datetime = DateTime.from_unix!(timestamp, :millisecond)
    assert diff = DateTime.diff(DateTime.utc_now(), datetime, :second)
    # I don't want to think about which order matters.
    assert abs(diff) <= 1
  end

  test "extract_timestamp/1 gets the original timestamp" do
    timestamp = System.system_time(:millisecond)
    uuid = UUIDv7.bingenerate()
    <<_::48, 7::4, rest::76>> = uuid
    new_uuid = <<timestamp::big-unsigned-48, 7::4, rest::76>>
    assert ^timestamp = UUIDv7.extract_timestamp(new_uuid)
  end
end
