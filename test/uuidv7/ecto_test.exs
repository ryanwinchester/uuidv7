defmodule UUIDv7.EctoTest do
  use ExUnit.Case, async: true

  @test_uuid "018e90d8-06e8-7f9f-bfd7-6730ba98a51b"
  @test_uuid_upper_case "018E90D8-06E8-7F9F-BFD7-6730BA98A51B"
  @test_uuid_invalid_characters "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  @test_uuid_invalid_format "xxxxxxxx-xxxx"
  @test_uuid_null "00000000-0000-0000-0000-000000000000"
  @test_uuid_binary <<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>

  test "cast" do
    assert UUIDv7.cast(@test_uuid) == {:ok, @test_uuid}
    assert UUIDv7.cast(@test_uuid_binary) == {:ok, @test_uuid}
    assert UUIDv7.cast(@test_uuid_upper_case) == {:ok, String.downcase(@test_uuid_upper_case)}
    assert UUIDv7.cast(@test_uuid_invalid_characters) == :error
    assert UUIDv7.cast(@test_uuid_null) == {:ok, @test_uuid_null}
    assert UUIDv7.cast(nil) == :error
  end

  test "cast!" do
    assert UUIDv7.cast!(@test_uuid) == @test_uuid

    assert_raise Ecto.CastError, "cannot cast nil to UUIDv7", fn ->
      assert UUIDv7.cast!(nil)
    end
  end

  test "load" do
    assert UUIDv7.load(@test_uuid_binary) == {:ok, @test_uuid}
    assert UUIDv7.load("") == :error

    assert_raise ArgumentError, ~r"trying to load string UUID as UUID:", fn ->
      UUIDv7.load(@test_uuid)
    end
  end

  test "load!" do
    assert UUIDv7.load!(@test_uuid_binary) == @test_uuid

    assert_raise ArgumentError, ~r"cannot load given binary as UUID:", fn ->
      UUIDv7.load!(@test_uuid_invalid_format)
    end
  end

  test "dump" do
    assert UUIDv7.dump(@test_uuid) == {:ok, @test_uuid_binary}
    assert UUIDv7.dump(@test_uuid_binary) == :error
  end

  test "dump!" do
    assert UUIDv7.dump!(@test_uuid) == @test_uuid_binary

    assert_raise ArgumentError, ~r"cannot dump given UUID to binary:", fn ->
      UUIDv7.dump!(@test_uuid_binary)
    end

    assert_raise ArgumentError, ~r"cannot dump given UUID to binary:", fn ->
      UUIDv7.dump!(@test_uuid_invalid_characters)
    end
  end

  test "generate" do
    assert <<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>> = UUIDv7.generate()
  end
end
