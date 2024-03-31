defmodule UUIDv7 do
  @moduledoc """
  UUIDv7 for Elixir.

  Used for generating version 7 UUIDs using microseconds for increased clock
  precision.

  Includes `Ecto.Type` implementations.

  ## Examples

      iex> UUIDv7.generate()
      "018e90d8-06e8-7f9f-bfd7-6730ba98a51b"

      iex> UUIDv7.bingenerate()
      <<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>

  """

  @typedoc """
  A hex-encoded UUID string.
  """
  @type t :: <<_::288>>

  @typedoc """
  A raw binary representation of a UUID.
  """
  @type raw :: <<_::128>>

  @doc """
  Generates a version 7 UUID using microseconds for increased clock precision.

  ## Example

      iex> UUIDv7.generate()
      "018e90d8-06e8-7f9f-bfd7-6730ba98a51b"

  """
  @spec generate() :: t
  def generate, do: bingenerate() |> encode()

  @doc """
  Generates a version 7 UUID from a microsecond timestamp.

  > #### Note {: .warning}
  >
  > This assumes that you are providing a microsecond-precision timestamp.

  ## Example

      iex> timestamp = DateTime.utc_now()
      iex> UUIDv7.generate(timestamp)
      "018e90d8-06e8-7f9f-bfd7-6730ba98a51b"

  """
  @spec generate(DateTime.t() | integer()) :: t
  def generate(timestamp), do: bingenerate(timestamp) |> encode()

  @doc """
  Generates a version 7 UUID in the binary format.

  ## Example

      iex> UUIDv7.bingenerate()
      <<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>

  """
  @spec bingenerate() :: raw
  def bingenerate do
    System.system_time(:microsecond) |> bingenerate()
  end

  @doc """
  Generates a version 7 UUID from an existing microsecond timestamp.

  > #### Note {: .warning}
  >
  > This assumes that you are providing a microsecond-precision timestamp.

  ## Examples

      iex> timestamp = System.system_time(:microsecond)
      iex> UUIDv7.bingenerate(timestamp)
      <<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>

      iex> timestamp = DateTime.utc_now()
      iex> UUIDv7.bingenerate(timestamp)
      <<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>

  """
  @spec bingenerate(integer | DateTime.t()) :: raw
  def bingenerate(%DateTime{} = datetime) do
    DateTime.to_unix(datetime, :microsecond) |> bingenerate()
  end

  def bingenerate(time) when is_integer(time) do
    # Replace left-most random bits (rand_a) with increased clock precision.
    # We could use up to 12 bits, but since using microseconds, we only need
    # to use 10 bits. The remaining 2, can be rand_a.
    ms = div(time, 1000)
    us = rem(time, 1000)

    <<rand_a::2, rand_b::62>> = :crypto.strong_rand_bytes(8)

    <<ms::big-unsigned-48, 7::4, us::big-unsigned-10, rand_a::2, 2::2, rand_b::62>>
  end

  @doc """
  Extract the timestamp (microsecond) from the UUID.

  > #### Note {: .warning}
  >
  > This assumes that the v7 UUID is encoded with the extra microsecond
  > precision in the 10 bits after the version.

  ## Example

      iex> UUIDv7.get_timestamp("018e90d8-06e8-7f9f-bfd7-6730ba98a51b")
      1711827060456999

  """
  @spec get_timestamp(t | raw) :: integer
  def get_timestamp(<<_::288>> = uuid) do
    decode(uuid) |> get_timestamp()
  end

  def get_timestamp(<<_::128>> = raw) do
    <<ms::big-unsigned-48, 7::4, us::big-unsigned-10, _::66>> = raw
    ms * 1000 + us
  end

  @doc """
  Encode a raw UUID to the string representation.

  ## Example

      iex> UUIDv7.encode(<<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>)
      "018e90d8-06e8-7f9f-bfd7-6730ba98a51b"

  """
  @spec encode(raw) :: t
  def encode(
        <<a1::4, a2::4, a3::4, a4::4, a5::4, a6::4, a7::4, a8::4, b1::4, b2::4, b3::4, b4::4,
          c1::4, c2::4, c3::4, c4::4, d1::4, d2::4, d3::4, d4::4, e1::4, e2::4, e3::4, e4::4,
          e5::4, e6::4, e7::4, e8::4, e9::4, e10::4, e11::4, e12::4>>
      ) do
    <<e(a1), e(a2), e(a3), e(a4), e(a5), e(a6), e(a7), e(a8), ?-, e(b1), e(b2), e(b3), e(b4), ?-,
      e(c1), e(c2), e(c3), e(c4), ?-, e(d1), e(d2), e(d3), e(d4), ?-, e(e1), e(e2), e(e3), e(e4),
      e(e5), e(e6), e(e7), e(e8), e(e9), e(e10), e(e11), e(e12)>>
  end

  @compile {:inline, e: 1}

  defp e(0), do: ?0
  defp e(1), do: ?1
  defp e(2), do: ?2
  defp e(3), do: ?3
  defp e(4), do: ?4
  defp e(5), do: ?5
  defp e(6), do: ?6
  defp e(7), do: ?7
  defp e(8), do: ?8
  defp e(9), do: ?9
  defp e(10), do: ?a
  defp e(11), do: ?b
  defp e(12), do: ?c
  defp e(13), do: ?d
  defp e(14), do: ?e
  defp e(15), do: ?f

  @doc """
  Decode a string representation of a UUID to the raw binary version.

  ## Example

      iex> UUIDv7.decode("018e90d8-06e8-7f9f-bfd7-6730ba98a51b")
      <<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>

  """
  @spec decode(t) :: raw | :error
  def decode(
        <<a1, a2, a3, a4, a5, a6, a7, a8, ?-, b1, b2, b3, b4, ?-, c1, c2, c3, c4, ?-, d1, d2, d3,
          d4, ?-, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12>>
      ) do
    <<d(a1)::4, d(a2)::4, d(a3)::4, d(a4)::4, d(a5)::4, d(a6)::4, d(a7)::4, d(a8)::4, d(b1)::4,
      d(b2)::4, d(b3)::4, d(b4)::4, d(c1)::4, d(c2)::4, d(c3)::4, d(c4)::4, d(d1)::4, d(d2)::4,
      d(d3)::4, d(d4)::4, d(e1)::4, d(e2)::4, d(e3)::4, d(e4)::4, d(e5)::4, d(e6)::4, d(e7)::4,
      d(e8)::4, d(e9)::4, d(e10)::4, d(e11)::4, d(e12)::4>>
  catch
    :error -> :error
  end

  def decode(_), do: :error

  @compile {:inline, d: 1}

  defp d(?0), do: 0
  defp d(?1), do: 1
  defp d(?2), do: 2
  defp d(?3), do: 3
  defp d(?4), do: 4
  defp d(?5), do: 5
  defp d(?6), do: 6
  defp d(?7), do: 7
  defp d(?8), do: 8
  defp d(?9), do: 9
  defp d(?A), do: 10
  defp d(?B), do: 11
  defp d(?C), do: 12
  defp d(?D), do: 13
  defp d(?E), do: 14
  defp d(?F), do: 15
  defp d(?a), do: 10
  defp d(?b), do: 11
  defp d(?c), do: 12
  defp d(?d), do: 13
  defp d(?e), do: 14
  defp d(?f), do: 15
  defp d(_), do: throw(:error)

  if Code.ensure_loaded?(Ecto.Type) do
    use Ecto.Type

    @doc false
    @impl Ecto.Type
    def type, do: :uuid

    # Callback invoked by autogenerate fields.
    @doc false
    @impl Ecto.Type
    def autogenerate, do: generate()

    @doc """
    Casts either a string in the canonical, human-readable UUID format or a
    16-byte binary to a UUID in its canonical, human-readable UUID format.

    If `uuid` is neither of these, `:error` will be returned.

    Since both binaries and strings are represent as binaries, this means some
    strings you may not expect are actually also valid UUIDs in their binary form
    and so will be casted into their string form.

    ## Examples

        iex> raw = <<1, 141, 236, 237, 26, 200, 116, 82, 179, 112, 220, 56, 9, 179, 208, 93>>
        iex> UUIDv7.cast(raw)
        {:ok, "018deced-1ac8-7452-b370-dc3809b3d05d"}

        iex> UUIDv7.cast("018deced-1ac8-7452-b370-dc3809b3d05d")
        {:ok, "018deced-1ac8-7452-b370-dc3809b3d05d"}

        iex> UUIDv7.cast("warehouse worker")
        {:ok, "77617265-686f-7573-6520-776f726b6572"}

    """
    @doc group: :ecto
    @impl Ecto.Type
    @spec cast(t | raw | any) :: {:ok, t} | :error
    def cast(uuid)

    def cast(
          <<a1, a2, a3, a4, a5, a6, a7, a8, ?-, b1, b2, b3, b4, ?-, c1, c2, c3, c4, ?-, d1, d2,
            d3, d4, ?-, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12>>
        ) do
      <<c(a1), c(a2), c(a3), c(a4), c(a5), c(a6), c(a7), c(a8), ?-, c(b1), c(b2), c(b3), c(b4),
        ?-, c(c1), c(c2), c(c3), c(c4), ?-, c(d1), c(d2), c(d3), c(d4), ?-, c(e1), c(e2), c(e3),
        c(e4), c(e5), c(e6), c(e7), c(e8), c(e9), c(e10), c(e11), c(e12)>>
    catch
      :error -> :error
    else
      hex_uuid -> {:ok, hex_uuid}
    end

    def cast(<<_::128>> = raw_uuid), do: {:ok, encode(raw_uuid)}
    def cast(_), do: :error

    @doc """
    Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
    """
    @doc group: :ecto
    @spec cast!(t | raw | any) :: t
    def cast!(uuid) do
      case cast(uuid) do
        {:ok, hex_uuid} -> hex_uuid
        :error -> raise Ecto.CastError, type: __MODULE__, value: uuid
      end
    end

    @compile {:inline, c: 1}

    defp c(?0), do: ?0
    defp c(?1), do: ?1
    defp c(?2), do: ?2
    defp c(?3), do: ?3
    defp c(?4), do: ?4
    defp c(?5), do: ?5
    defp c(?6), do: ?6
    defp c(?7), do: ?7
    defp c(?8), do: ?8
    defp c(?9), do: ?9
    defp c(?A), do: ?a
    defp c(?B), do: ?b
    defp c(?C), do: ?c
    defp c(?D), do: ?d
    defp c(?E), do: ?e
    defp c(?F), do: ?f
    defp c(?a), do: ?a
    defp c(?b), do: ?b
    defp c(?c), do: ?c
    defp c(?d), do: ?d
    defp c(?e), do: ?e
    defp c(?f), do: ?f
    defp c(_), do: throw(:error)

    @doc """
    Converts a string representing a UUID into a raw binary.
    """
    @doc group: :ecto
    @impl Ecto.Type
    @spec dump(uuid_string :: t | any) :: {:ok, raw} | :error
    def dump(uuid_string)

    def dump(uuid_string) do
      case decode(uuid_string) do
        :error -> :error
        raw_uuid -> {:ok, raw_uuid}
      end
    end

    @doc """
    Same as `dump/1` but raises `Ecto.ArgumentError` on invalid arguments.
    """
    @doc group: :ecto
    @spec dump!(t | any) :: raw
    def dump!(uuid) do
      with :error <- decode(uuid) do
        raise ArgumentError, "cannot dump given UUID to binary: #{inspect(uuid)}"
      end
    end

    @doc """
    Converts a binary UUID into a string.
    """
    @doc group: :ecto
    @impl Ecto.Type
    @spec load(raw | any) :: {:ok, t} | :error
    def load(<<_::128>> = raw_uuid), do: {:ok, encode(raw_uuid)}

    def load(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>> = string) do
      raise ArgumentError,
            "trying to load string UUID as UUID: #{inspect(string)}. " <>
              "Maybe you wanted to declare :uuid as your database field?"
    end

    def load(_), do: :error

    @doc """
    Same as `load/1` but raises `Ecto.ArgumentError` on invalid arguments.
    """
    @doc group: :ecto
    @spec load!(raw | any) :: t
    def load!(value) do
      case load(value) do
        {:ok, hex_uuid} -> hex_uuid
        :error -> raise ArgumentError, "cannot load given binary as UUID: #{inspect(value)}"
      end
    end
  end
end
