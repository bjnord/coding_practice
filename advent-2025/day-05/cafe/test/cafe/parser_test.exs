defmodule Cafe.ParserTest do
  use ExUnit.Case
  doctest Cafe.Parser, import: true

  import Cafe.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        3-5
        10-14
        16-20
        12-18

        1
        5
        8
        11
        17
        32
        """,
        exp_inventory: {
          [
            {3, 5},
            {10, 14},
            {16, 20},
            {12, 18},
          ],
          [
            1,
            5,
            8,
            11,
            17,
            32,
          ]
        },
      ]
    end

    test "parser gets expected inventory", fixture do
      act_inventory =
        fixture.input
        |> parse_input_string()
      assert act_inventory == fixture.exp_inventory
    end
  end
end
