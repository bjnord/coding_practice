alias Race.Graph

grid = "private/input.txt"
       |> Race.Parser.parse_input_file()
graph = grid
        |> Graph.new()
IO.puts("")

Benchee.run(
  %{
    "cheats" => fn -> Race.cheats(grid) end,
  },
  profile_after: false
)

Benchee.run(
  %{
    "lowest_cost_from_grid" => fn -> Graph.lowest_cost(Graph.new(grid)) end,
    "lowest_cost_from_graph" => fn -> Graph.lowest_cost(graph) end,
  },
  profile_after: false
)
