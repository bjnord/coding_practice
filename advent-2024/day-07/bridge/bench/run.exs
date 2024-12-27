Code.require_file("test/support/functions.ex")

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
  parallel: 2,
  profile_after: false
)

Benchee.run(
  %{
    "string_op_concat" => fn -> Bridge.TestSupport.string_op_concat(2024, 1225) end,
    "log10_op_concat" => fn -> Bridge.op_concat(2024, 1225) end,
  },
  parallel: 2,
  profile_after: false
)
