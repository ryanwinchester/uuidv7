Benchee.run(%{
  "uuid_v7 raw" => fn ->
    UUIDv7.bingenerate()
  end,
  "uniq v7 raw" => fn ->
    Uniq.UUID.uuid7(:raw)
  end
})
