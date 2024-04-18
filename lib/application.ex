defmodule UUIDv7.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    # Put the timestamp ref into persistent_term store.
    # This is used in the `UUIDv7.Clock` module to determine the most recent
    # timestamp, and protect against time leap backwards.
    clock_atomics_ref = :atomics.new(1, signed: false)
    :persistent_term.put(UUIDv7.Clock, clock_atomics_ref)

    children = [
      UUIDv7.Clock
    ]

    opts = [strategy: :one_for_one, name: UUIDv7.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
