defmodule UUIDv7.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      UUIDv7.Clock
    ]

    opts = [strategy: :one_for_one, name: UUIDv7.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
