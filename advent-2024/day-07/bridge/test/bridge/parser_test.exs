defmodule Bridge.ParserTest do
  use ExUnit.Case
  doctest Bridge.Parser, import: true

  import Bridge.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        190: 10 19
        3267: 81 40 27
        83: 17 5
        156: 15 6
        7290: 6 8 6 15
        161011: 16 10 13
        192: 17 8 14
        21037: 9 7 18 13
        292: 11 6 16 20
        """,
        exp_equations: [
          {190, [10, 19]},
          {3267, [81, 40, 27]},
          {83, [17, 5]},
          {156, [15, 6]},
          {7290, [6, 8, 6, 15]},
          {161011, [16, 10, 13]},
          {192, [17, 8, 14]},
          {21037, [9, 7, 18, 13]},
          {292, [11, 6, 16, 20]},
        ],
      ]
    end

    test "parser gets expected equations", fixture do
      act_equations = fixture.input
                      |> parse_input_string()
                      |> Enum.to_list()
      assert act_equations == fixture.exp_equations
    end
  end
end
