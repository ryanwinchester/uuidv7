Benchee.run(%{
  "uuid_v7 string" => fn ->
    UUIDv7.generate()
  end,
  "uniq v7 string" => fn ->
    Uniq.UUID.uuid7(:default)
  end
})
