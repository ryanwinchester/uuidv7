set = [
  table: [
    :named_table,
    :public,
    :set
  ]
]

set_read = [
  table: [
    :named_table,
    :public,
    :set,
    {:read_concurrency, true}
  ]
]

set_write = [
  table: [
    :named_table,
    :public,
    :set,
    {:write_concurrency, true}
  ]
]

set_read_write = [
  table: [
    :named_table,
    :public,
    :set,
    {:read_concurrency, true},
    {:write_concurrency, true}
  ]
]

ordered_set = [
  table: [
    :named_table,
    :public,
    :ordered_set
  ]
]

ordered_set_read = [
  table: [
    :named_table,
    :public,
    :ordered_set,
    {:read_concurrency, true}
  ]
]

ordered_set_write = [
  table: [
    :named_table,
    :public,
    :ordered_set,
    {:write_concurrency, true}
  ]
]

ordered_set_read_write = [
  table: [
    :named_table,
    :public,
    :ordered_set,
    {:read_concurrency, true},
    {:write_concurrency, true}
  ]
]

alias UUIDv7.Clock

Benchee.run(
  %{
    "set" =>
      {fn _ ->
         for _ <- 1..1_000_000 do
           <<seed::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
           Clock.next(<<seed::big-unsigned-17>>)
         end
       end, before_scenario: fn _ -> Clock.start_link(set) end},
    "set_read" =>
      {fn _ ->
         for _ <- 1..1_000_000 do
           <<seed::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
           Clock.next(<<seed::big-unsigned-17>>)
         end
       end, before_scenario: fn _ -> Clock.start_link(set_read) end},
    "set_write" =>
      {fn _ ->
         for _ <- 1..1_000_000 do
           <<seed::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
           Clock.next(<<seed::big-unsigned-17>>)
         end
       end, before_scenario: fn _ -> Clock.start_link(set_write) end},
    "set_read_write" =>
      {fn _ ->
         for _ <- 1..1_000_000 do
           <<seed::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
           Clock.next(<<seed::big-unsigned-17>>)
         end
       end, before_scenario: fn _ -> Clock.start_link(set_read_write) end},
    "ordered_set" =>
      {fn _ ->
         for _ <- 1..1_000_000 do
           <<seed::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
           Clock.next(<<seed::big-unsigned-17>>)
         end
       end, before_scenario: fn _ -> Clock.start_link(ordered_set) end},
    "ordered_set_read" =>
      {fn _ ->
         for _ <- 1..1_000_000 do
           <<seed::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
           Clock.next(<<seed::big-unsigned-17>>)
         end
       end, before_scenario: fn _ -> Clock.start_link(ordered_set_read) end},
    "ordered_set_write" =>
      {fn _ ->
         for _ <- 1..1_000_000 do
           <<seed::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
           Clock.next(<<seed::big-unsigned-17>>)
         end
       end, before_scenario: fn _ -> Clock.start_link(ordered_set_write) end},
    "ordered_set_read_write" =>
      {fn _ ->
         for _ <- 1..1_000_000 do
           <<seed::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
           Clock.next(<<seed::big-unsigned-17>>)
         end
       end, before_scenario: fn _ -> Clock.start_link(ordered_set_read_write) end}
  },
  after_scenario: fn _ -> GenServer.stop(Clock) end
)
