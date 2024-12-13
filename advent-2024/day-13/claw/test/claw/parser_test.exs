defmodule Claw.ParserTest do
  use ExUnit.Case
  doctest Claw.Parser, import: true

  import Claw.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        Button A: X+94, Y+34
        Button B: X+22, Y+67
        Prize: X=8400, Y=5400

        Button A: X+26, Y+66
        Button B: X+67, Y+21
        Prize: X=12748, Y=12176

        Button A: X+17, Y+86
        Button B: X+84, Y+37
        Prize: X=7870, Y=6450

        Button A: X+69, Y+23
        Button B: X+27, Y+71
        Prize: X=18641, Y=10279
        """,
        exp_machines: [
          %{
            a: {34, 94},
            b: {67, 22},
            prize: {5400, 8400},
          },
          %{
            a: {66, 26},
            b: {21, 67},
            prize: {12176, 12748},
          },
          %{
            a: {86, 17},
            b: {37, 84},
            prize: {6450, 7870},
          },
          %{
            a: {23, 69},
            b: {71, 27},
            prize: {10279, 18641},
          },
        ],
      ]
    end

    test "parser gets expected machines", fixture do
      act_machines = fixture.input
                     |> parse_input_string()
      assert act_machines == fixture.exp_machines
    end
  end
end
