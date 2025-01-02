grid = "private/input.txt"
       |> Xmas.Parser.parse_input_file()

# Name                ips        average  deviation         median         99th %
# count_all          4.96      201.43 ms    ±11.09%      199.43 ms      248.07 ms
# count_x           30.74       32.53 ms    ±16.88%       30.62 ms       54.09 ms

Benchee.run(
  %{
    "count_x" => fn -> Xmas.count_xmas(grid) end,
  },
  parallel: 1,
  profile_after: false
)
