grid = "private/input.txt"
       |> Guard.Parser.parse_input_file()

Benchee.run(
  %{
    #"squares" => fn -> Guard.squares_walked(grid) end,
    "slow" => fn -> Guard.loop_obstacles(grid) end,
  },
  profile_after: true
)
