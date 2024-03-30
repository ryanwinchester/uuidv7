# UUIDv7

UUIDv7 for Elixir and Ecto, using microseconds.

## Installation

The package can be installed by adding `uuid_v7` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uuid_v7, "~> 0.1.0"}
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

