equation = "private/input.txt"
           |> Bridge.Parser.parse_input_file()
           |> Enum.at(25)
           |> IO.inspect(label: "equation")
IO.puts("")

Benchee.run(
  %{
    "op_atoms" => fn -> Bridge.atom_solvable3?(equation) end,
    "dynamic" => fn -> Bridge.solvable?(equation, [:+, :*, :||]) end,
    "dynamic_big" => fn -> Bridge.solvable?(equation, [:*, :||, :+]) end,
    "dynamic_bigger" => fn -> Bridge.solvable?(equation, [:||, :*, :+]) end,
  },
  profile_after: false
)
