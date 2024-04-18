# UUIDv7

[![CI](https://github.com/ryanwinchester/uuidv7/actions/workflows/ci.yml/badge.svg)](https://github.com/ryanwinchester/uuidv7/actions/workflows/ci.yml)
 [![Hex.pm](https://img.shields.io/hexpm/v/uuid_v7)](https://hex.pm/packages/uuid_v7)
 [![Hex.pm](https://img.shields.io/hexpm/dt/uuid_v7)](https://hex.pm/packages/uuid_v7)
 [![Hex.pm](https://img.shields.io/hexpm/l/uuid_v7)](https://github.com/ryanwinchester/uuidv7/blob/main/LICENSE)

UUIDv7 for Elixir and (optionally) Ecto, using an 18-bit randomly-seeded counter.

Uses suggestions described in **[Section 6.2](https://www.ietf.org/archive/id/draft-ietf-uuidrev-rfc4122bis-14.html#name-monotonicity-and-counters)** from [this IETF Draft](https://www.ietf.org/archive/id/draft-ietf-uuidrev-rfc4122bis-14.html)
to add additional sort precision to a version 7 UUID.

## When should I use this package?

- You want sequential, time-based, ordered IDs (per-node).
- You are willing to trade a small amount of raw performance for these
  guarantees. You are taking a hit for backwards time-leap protection and the
  counter with rollover protection.

## When should I not use this package?

- You don't care about sort/order precision beyond milliseconds.

There are other UUID packages, that only have millisecond precision, for example:

- [martinthenth/uuidv7](https://github.com/martinthenth/uuidv7)
- [bitwalker/uniq](https://github.com/bitwalker/uniq)

## Installation

The package can be installed by adding `uuid_v7` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uuid_v7, "~> 0.4.2"}
  ]
end
```

## Usage

```elixir
iex> UUIDv7.generate()
"018e90d8-06e8-7f9f-bfd7-6730ba98a51b"

iex> UUIDv7.bingenerate()
<<1, 142, 144, 216, 124, 16, 127, 196, 158, 92, 92, 74, 83, 46, 116, 173>>
```

## Usage with Ecto

Use this the same way you would use `Ecto.UUID`. For example:

```elixir
defmodule MyApp.Blog.Post do
  use Ecto.Schema

  @primary_key {:id, UUIDv7, autogenerate: true}

  @foreign_key_type UUIDv7

  schema "blog_posts" do
    field :text, :string
    # etc.
  end
end
```

