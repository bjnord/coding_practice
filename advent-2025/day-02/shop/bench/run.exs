ranges =
  "private/input.txt"
  |> Shop.Parser.parse_input_file()
  |> Enum.slice(8, 10)
  |> IO.inspect(label: "ranges")
IO.puts("")

Benchee.run(
  %{
    "slow part 2" => fn -> ranges |> Enum.map(&Shop.slow_sum_repeated/1) end,
    "fast part 2" => fn -> ranges |> Enum.map(&Shop.sum_repeated/1) end,
  },
  parallel: 2,
  profile_after: false
)
