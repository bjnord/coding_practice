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
          %Maze{  # FIXME
            start: {1, 1},
            tiles: [
            ],
          },
          %Maze{  # FIXME
            start: {2, 0},
            tiles: [
            ],
          },
          %Maze{  # FIXME
            start: {2, 0},
            tiles: [
            ],
          },
        ],
      ]
    end

    test "parser gets expected entries", fixture do
      act_mazes = fixture.inputs
                  |> Enum.map(&parse_input_string/1)
                  |> Enum.take(1)  # FIXME
      assert act_mazes == Enum.take(fixture.exp_mazes, 1)  # FIXME
    end
  end
end
