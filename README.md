# UUIDv7

[![CI](https://github.com/ryanwinchester/uuidv7/actions/workflows/ci.yml/badge.svg)](https://github.com/ryanwinchester/uuidv7/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/uuid_v7)](https://hex.pm/packages/uuid_v7)
[![Hex.pm](https://img.shields.io/hexpm/dt/uuid_v7)](https://hex.pm/packages/uuid_v7)
[![Hex.pm](https://img.shields.io/hexpm/l/uuid_v7)](https://github.com/ryanwinchester/uuidv7/blob/main/LICENSE)

UUIDv7 for Elixir and (optionally) Ecto, using always-increasing clock-precision for monotonicity.

Uses suggestions described in **[Section 6.2](https://www.rfc-editor.org/rfc/rfc9562#name-monotonicity-and-counters)** from [RFC 9562](https://www.rfc-editor.org/rfc/rfc9562)
to add additional sort precision to a version 7 UUID.

## When should I use this package?

- You want sequential, time-based, ordered IDs (per-node).
- You are willing to trade a small amount of raw performance for these
  guarantees.

NOTE: In this library, sequential UUIDs and ordering are more important than time precision and performance.
We take a slight hit in both of those areas to ensure that the UUIDs are in order. For example, in the case of a
backwards time leap, or even concurrent requests at the same time, we continue with the previously used
timestamp and increment the clock precision by a minimum step.

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
    {:uuid_v7, "~> 0.6.0"}
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

  @primary_key {:id, UUIDv7.Type, autogenerate: true}

  @foreign_key_type UUIDv7.Type

  schema "blog_posts" do
    field :text, :string
    # etc.
  end
end
```

To use UUIDs for everything in your migrations, it's easiest to just add that as the
default type in your config. e.g.:

```elixir
# config/config.exs
config :app, App.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]
```

## Benchmarks

Run benchmarks with

```
MIX_ENV=bench mix run bench/filename.exs
```

Where `filename.exs` is the name of one of the benchmark files in the `bench` directory.

### Compared to `Uniq.UUID`

(which has no extra clock precision, only millisecond precision.)

#### String:

```
Name                     ips        average  deviation         median         99th %
uniq v7 string        2.13 M      468.64 ns  ±4155.60%         417 ns         584 ns
uuid_v7 string        1.98 M      504.57 ns  ±3338.92%         458 ns         667 ns

Comparison:
uniq v7 string        2.13 M
uuid_v7 string        1.98 M - 1.08x slower +35.93 ns
```

#### Raw (binary):

```
Name                  ips        average  deviation         median         99th %
uniq v7 raw        3.14 M      318.58 ns  ±8234.89%         250 ns         417 ns
uuid_v7 raw        2.85 M      351.26 ns  ±4999.60%         292 ns         459 ns

Comparison:
uniq v7 raw        3.14 M
uuid_v7 raw        2.85 M - 1.10x slower +32.69 ns
```
