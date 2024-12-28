Code.require_file("test/support/functions.ex")

stone_map = "private/input.txt"
            |> Pluto.Parser.parse_input_file()

Benchee.run(
  %{
    "string" => fn -> Pluto.TestSupport.string_divide(20241225) end,
    "log10" => fn -> Pluto.divide(20241225) end,
  },
  profile_after: false
)

Benchee.run(
  %{
    "n_stones" => fn -> Pluto.n_stones(stone_map, 75) end,
    "mp_n_stones" => fn -> Pluto.mp_n_stones(stone_map, 75) end,
  },
  parallel: 1,
  profile_after: false
)
