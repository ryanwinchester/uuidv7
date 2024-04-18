defmodule UUIDv7.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      UUIDv7.Clock
    ]

    # Put the timestamp ref into persistent_term store.
    # This is used in the `Clock` module to determine the most recent timestamp.
    ref = :atomics.new(1, signed: false)
    :persistent_term.put(:timestamp_ref, ref)

    opts = [strategy: :one_for_one, name: UUIDv7.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
