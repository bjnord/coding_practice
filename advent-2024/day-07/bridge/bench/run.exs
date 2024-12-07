equation = "private/input.txt"
           |> Bridge.Parser.parse_input_file()
           |> Enum.at(25)
           |> IO.inspect(label: "equation")
IO.puts("")

Benchee.run(
  %{
    # the order of the operators doesn't make a significant difference
    "dynamic" => fn -> Bridge.solvable?(equation, [:+, :*, :||]) end,
    "dynamic_big" => fn -> Bridge.solvable?(equation, [:*, :||, :+]) end,
    "dynamic_bigger" => fn -> Bridge.solvable?(equation, [:||, :*, :+]) end,
  },
  profile_after: false
)
