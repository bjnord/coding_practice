Code.require_file("test/support/string_n_digits.ex")

Benchee.run(
  %{
    "string" => fn -> History.TestSupport.string_n_digits(20241225) end,
    "log10" => fn -> History.Math.n_digits(20241225) end,
  },
  profile_after: false
)
