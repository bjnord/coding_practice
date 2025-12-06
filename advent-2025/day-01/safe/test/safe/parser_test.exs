defmodule Safe.ParserTest do
  use ExUnit.Case
  doctest Safe.Parser, import: true

  import Safe.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        L68
        L30
        R48
        L5
        R60
        L55
        L1
        L99
        R14
        L82
        """,
        exp_rotations: [
          {"L68", -68},
          {"L30", -30},
          {"R48",  48},
          {"L5",   -5},
          {"R60",  60},
          {"L55", -55},
          {"L1",   -1},
          {"L99", -99},
          {"R14",  14},
          {"L82", -82},
        ],
      ]
    end

    test "parser gets expected rotations", fixture do
      act_rotations =
        fixture.input
        |> parse_input_string()
        |> Enum.to_list()

      assert act_rotations == fixture.exp_rotations
    end
  end
end
