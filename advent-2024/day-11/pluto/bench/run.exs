Code.require_file("test/support/functions.ex")

Benchee.run(
  %{
    "string" => fn -> Pluto.TestSupport.string_divide(20241225) end,
    "log10" => fn -> Pluto.divide(20241225) end,
  },
  profile_after: false
)
