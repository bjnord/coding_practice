defmodule Antenna.ParserTest do
  use ExUnit.Case
  doctest Antenna.Parser, import: true

  import Antenna.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        ......#....#
        ...#....0...
        ....#0....#.
        ..#....0....
        ....0....#..
        .#....A.....
        ...#........
        #......#....
        ........A...
        .........A..
        ..........#.
        ..........#.
        """,
        exp_antenna_chart: {
          [
            {{1, 8}, ?0},
            {{2, 5}, ?0},
            {{3, 7}, ?0},
            {{4, 4}, ?0},
            {{5, 6}, ?A},
            {{8, 8}, ?A},
            {{9, 9}, ?A},
          ],
          {12, 12},
        },
      ]
    end

    test "parser gets expected antennas", fixture do
      act_antenna_chart = fixture.input
                          |> parse_input_string()
      assert act_antenna_chart == fixture.exp_antenna_chart
    end
  end
end
