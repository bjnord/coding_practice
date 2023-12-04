defmodule Gondola.ParserTest do
  use ExUnit.Case
  doctest Gondola.Parser, import: true

  import Gondola.Parser
  alias Gondola.Schematic, as: Schematic

  describe "puzzle example" do
    setup do
      [
        input: """
        467..114..
        ...*......
        ..35..633.
        ......#...
        617*......
        .....+.58.
        ..592.....
        ......755.
        ...$.*....
        .664.598..
        """,
        exp_schematic: %Schematic{
          parts: [
            %{number: 467, y: 0, x1: 0, x2: 2},
            %{number: 114, y: 0, x1: 5, x2: 7},
            %{number: 35,  y: 2, x1: 2, x2: 3},
            %{number: 633, y: 2, x1: 6, x2: 8},
            %{number: 617, y: 4, x1: 0, x2: 2},
            %{number: 58,  y: 5, x1: 7, x2: 8},
            %{number: 592, y: 6, x1: 2, x2: 4},
            %{number: 755, y: 7, x1: 6, x2: 8},
            %{number: 664, y: 9, x1: 1, x2: 3},
            %{number: 598, y: 9, x1: 5, x2: 7},
          ],
          symbols: [
            %{symbol: "*", y: 1, x: 3},
            %{symbol: "#", y: 3, x: 6},
            %{symbol: "*", y: 4, x: 3},
            %{symbol: "+", y: 5, x: 5},
            %{symbol: "$", y: 8, x: 3},
            %{symbol: "*", y: 8, x: 5},
          ],
        },
      ]
    end

    test "parser gets expected schematic", fixture do
      act_schematic = fixture.input
                      |> parse_input_string()
      assert act_schematic == fixture.exp_schematic
    end

    test "same part number appears 2+ times on same line" do
      act = parse_line(".633..633.\n")
      exp = %{parts: [%{number: 633, x1: 1, x2: 3}, %{number: 633, x1: 6, x2: 8}], symbols: []}
      assert act == exp
    end

    test "part number appears at end of line" do
      act = parse_line("......=555\n")
      exp = %{parts: [%{number: 555, x1: 7, x2: 9}], symbols: [%{symbol: "=", x: 6}]}
      assert act == exp
    end
  end
end
