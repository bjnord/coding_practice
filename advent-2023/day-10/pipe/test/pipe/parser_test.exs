defmodule Pipe.ParserTest do
  use ExUnit.Case
  doctest Pipe.Parser, import: true

  import Pipe.Parser
  alias Pipe.Maze

  describe "puzzle example" do
    setup do
      [
        inputs: [
          """
          .....
          .S-7.
          .|.|.
          .L-J.
          .....
          """,
          """
          -L|F7
          7S-7|
          L|7||
          -L-J|
          L|-JF
          """,
          """
          ..F7.
          .FJ|.
          SJ.L7
          |F--J
          LJ...
          """,
          """
          7-F7-
          .FJ|7
          SJLL7
          |F--J
          LJ.LJ
          """,
        ],
        exp_mazes: [
          %Maze{
            start: {1, 1},
            tiles: %{
              {1, 1} => ?F,
              {1, 2} => ?-,
              {1, 3} => ?7,
              {2, 3} => ?|,
              {3, 3} => ?J,
              {3, 2} => ?-,
              {3, 1} => ?L,
              {2, 1} => ?|,
            },
          },
          %Maze{
            start: {1, 1},
            tiles: %{
              {0, 0} => ?-,
              {0, 1} => ?L,
              {0, 2} => ?|,
              {0, 3} => ?F,
              {0, 4} => ?7,
              {1, 0} => ?7,
              {1, 1} => ?F,
              {1, 2} => ?-,
              {1, 3} => ?7,
              {1, 4} => ?|,
              {2, 0} => ?L,
              {2, 1} => ?|,
              {2, 2} => ?7,
              {2, 3} => ?|,
              {2, 4} => ?|,
              {3, 0} => ?-,
              {3, 1} => ?L,
              {3, 2} => ?-,
              {3, 3} => ?J,
              {3, 4} => ?|,
              {4, 0} => ?L,
              {4, 1} => ?|,
              {4, 2} => ?-,
              {4, 3} => ?J,
              {4, 4} => ?F,
            },
          },
          %Maze{
            start: {2, 0},
            tiles: %{
              {0, 2} => ?F,
              {0, 3} => ?7,
              {1, 1} => ?F,
              {1, 2} => ?J,
              {1, 3} => ?|,
              {2, 0} => ?F,
              {2, 1} => ?J,
              {2, 3} => ?L,
              {2, 4} => ?7,
              {3, 0} => ?|,
              {3, 1} => ?F,
              {3, 2} => ?-,
              {3, 3} => ?-,
              {3, 4} => ?J,
              {4, 0} => ?L,
              {4, 1} => ?J,
            },
          },
          %Maze{
            start: {2, 0},
            tiles: %{
              {0, 0} => ?7,
              {0, 1} => ?-,
              {0, 2} => ?F,
              {0, 3} => ?7,
              {0, 4} => ?-,
              {1, 1} => ?F,
              {1, 2} => ?J,
              {1, 3} => ?|,
              {1, 4} => ?7,
              {2, 0} => ?F,
              {2, 1} => ?J,
              {2, 2} => ?L,
              {2, 3} => ?L,
              {2, 4} => ?7,
              {3, 0} => ?|,
              {3, 1} => ?F,
              {3, 2} => ?-,
              {3, 3} => ?-,
              {3, 4} => ?J,
              {4, 0} => ?L,
              {4, 1} => ?J,
              {4, 3} => ?L,
              {4, 4} => ?J,
            },
          },
        ],
      ]
    end

    test "parser gets expected entries", fixture do
      act_mazes = fixture.inputs
                  |> Enum.map(&parse_input_string/1)
      assert act_mazes == fixture.exp_mazes
    end
  end
end
