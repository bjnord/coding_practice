defmodule Dish.ParserTest do
  use ExUnit.Case
  doctest Dish.Parser, import: true

  import Dish.Parser
  alias Dish.Platform

  describe "puzzle example" do
    setup do
      [
        inputs: [
          """
          O....#....
          O.OO#....#
          .....##...
          OO.#O....O
          .O.....O#.
          O.#..O.#.#
          ..O..#O..O
          .......O..
          #....###..
          #OO..#....
          """,
          """
          OOOO.#.O..
          OO..#....#
          OO..O##..O
          O..#.OO...
          ........#.
          ..#....#.#
          ..O..#.O.O
          ..O.......
          #....###..
          #....#....
          """,
        ],
        exp_platforms: [
          %Platform{
            rocks: %{
              {0, 0} => :O,
              {0, 5} => :M,
              {1, 0} => :O,
              {1, 2} => :O,
              {1, 3} => :O,
              {1, 4} => :M,
              {1, 9} => :M,
              {2, 5} => :M,
              {2, 6} => :M,
              {3, 0} => :O,
              {3, 1} => :O,
              {3, 3} => :M,
              {3, 4} => :O,
              {3, 9} => :O,
              {4, 1} => :O,
              {4, 7} => :O,
              {4, 8} => :M,
              {5, 0} => :O,
              {5, 2} => :M,
              {5, 5} => :O,
              {5, 7} => :M,
              {5, 9} => :M,
              {6, 2} => :O,
              {6, 5} => :M,
              {6, 6} => :O,
              {6, 9} => :O,
              {7, 7} => :O,
              {8, 0} => :M,
              {8, 5} => :M,
              {8, 6} => :M,
              {8, 7} => :M,
              {9, 0} => :M,
              {9, 1} => :O,
              {9, 2} => :O,
              {9, 5} => :M,
            },
            size: {10, 10},
            tilt: :flat,
          },
          %Platform{
            rocks: %{
              {0, 0} => :O,
              {0, 1} => :O,
              {0, 2} => :O,
              {0, 3} => :O,
              {0, 5} => :M,
              {0, 7} => :O,
              {1, 0} => :O,
              {1, 1} => :O,
              {1, 4} => :M,
              {1, 9} => :M,
              {2, 0} => :O,
              {2, 1} => :O,
              {2, 4} => :O,
              {2, 5} => :M,
              {2, 6} => :M,
              {2, 9} => :O,
              {3, 0} => :O,
              {3, 3} => :M,
              {3, 5} => :O,
              {3, 6} => :O,
              {4, 8} => :M,
              {5, 2} => :M,
              {5, 7} => :M,
              {5, 9} => :M,
              {6, 2} => :O,
              {6, 5} => :M,
              {6, 7} => :O,
              {6, 9} => :O,
              {7, 2} => :O,
              {8, 0} => :M,
              {8, 5} => :M,
              {8, 6} => :M,
              {8, 7} => :M,
              {9, 0} => :M,
              {9, 5} => :M,
            },
            size: {10, 10},
            tilt: :flat,
          },
        ],
      ]
    end

    test "parser gets expected platforms", fixture do
      act_platforms = fixture.inputs
                      |> Enum.map(&parse_input_string/1)
      assert act_platforms == fixture.exp_platforms
    end
  end
end
