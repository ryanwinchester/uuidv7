alias UUIDv7.Clock

{:ok, _pid} = Clock.start_link([])

Benchee.run(%{
  "uuid_v7 raw" => fn ->
    UUIDv7.bingenerate()
  end,
  "uuid_v7 string" => fn ->
    UUIDv7.generate()
  end,
  "uniq v7 raw" => fn ->
    Uniq.UUID.uuid7(:raw)
  end,
  "uniq v7 string" => fn ->
    Uniq.UUID.uuid7(:default)
  end
})
