grid = "private/input.txt"
       |> Guard.Parser.parse_input_file()

Benchee.run(
  %{
    "brute" => fn -> Guard.brute_loop_obstacles(grid) end,
    "selective" => fn -> Guard.loop_obstacles(grid) end,
  },
  profile_after: false
)
