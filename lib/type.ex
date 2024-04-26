if Code.ensure_loaded?(Ecto.Type) do
  defmodule UUIDv7.Type do
    @moduledoc """
    Ecto type for UUIDv7.
    """
    use Ecto.Type

    @type t :: UUIDv7.t()
    @type raw :: UUIDv7.raw()

    @doc false
    @impl Ecto.Type
    def type, do: :uuid

    # Callback invoked by autogenerate fields.
    @doc false
    @impl Ecto.Type
    def autogenerate, do: UUIDv7.generate()

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

    def cast(<<_::128>> = raw_uuid), do: {:ok, UUIDv7.encode(raw_uuid)}
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
      case UUIDv7.decode(uuid_string) do
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
      with :error <- UUIDv7.decode(uuid) do
        raise ArgumentError, "cannot dump given UUID to binary: #{inspect(uuid)}"
      end
    end

    @doc """
    Converts a binary UUID into a string.
    """
    @doc group: :ecto
    @impl Ecto.Type
    @spec load(raw | any) :: {:ok, t} | :error
    def load(<<_::128>> = raw_uuid), do: {:ok, UUIDv7.encode(raw_uuid)}

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
