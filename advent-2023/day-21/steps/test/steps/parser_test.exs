defmodule Steps.ParserTest do
  use ExUnit.Case
  doctest Steps.Parser, import: true

  import Steps.Parser
  alias Steps.Garden

  describe "puzzle example" do
    setup do
      [
        inputs: [
          """
          ...........
          .....###.#.
          .###.##..#.
          ..#.#...#..
          ....#.#....
          .##..S####.
          .##..#...#.
          .......##..
          .##.#.####.
          .##..##.##.
          ...........
          """,
        ],
        exp_gardens: [
          %Garden{
            start: {5, 5},
            size: %{y: 10, x: 10},
            tiles: %{
              {1, 5} => ?#,
              {1, 6} => ?#,
              {1, 7} => ?#,
              {1, 9} => ?#,
              {2, 1} => ?#,
              {2, 2} => ?#,
              {2, 3} => ?#,
              {2, 5} => ?#,
              {2, 6} => ?#,
              {2, 9} => ?#,
              {3, 2} => ?#,
              {3, 4} => ?#,
              {3, 8} => ?#,
              {4, 4} => ?#,
              {4, 6} => ?#,
              {5, 1} => ?#,
              {5, 2} => ?#,
              {5, 6} => ?#,
              {5, 7} => ?#,
              {5, 8} => ?#,
              {5, 9} => ?#,
              {6, 1} => ?#,
              {6, 2} => ?#,
              {6, 5} => ?#,
              {6, 9} => ?#,
              {7, 7} => ?#,
              {7, 8} => ?#,
              {8, 1} => ?#,
              {8, 2} => ?#,
              {8, 4} => ?#,
              {8, 6} => ?#,
              {8, 7} => ?#,
              {8, 8} => ?#,
              {8, 9} => ?#,
              {9, 1} => ?#,
              {9, 2} => ?#,
              {9, 5} => ?#,
              {9, 6} => ?#,
              {9, 8} => ?#,
              {9, 9} => ?#,
            },
          },
        ],
      ]
    end

    test "parser gets expected gardens", fixture do
      act_gardens = fixture.inputs
                  |> Enum.map(&parse_input_string/1)
      assert act_gardens == fixture.exp_gardens
    end
  end
end
