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
        start_inputs: [
          """
          .....
          .F-S.
          .|.|.
          .L-J.
          .....
          """,
          """
          .....
          .F-7.
          .|.S.
          .L-J.
          .....
          """,
          """
          .....
          .F-7.
          .|.|.
          .L-S.
          .....
          """,
          """
          .....
          .F-7.
          .|.|.
          .LSJ.
          .....
          """,
          """
          .....
          .F-7.
          .|.|.
          .S-J.
          .....
          """,
        ],
        invalid_inputs: [
          """
          .....
          .S.7.
          .|.|.
          .L-J.
          .....
          """,
          """
          .|...
          .S-7.
          .|.|.
          .L-J.
          .....
          """,
        ],
        invalid_messages: [
          "invalid connect N=false S=true E=false W=false",
          "invalid connect N=true S=true E=true W=false",
        ],
        exp_mazes: [
          %Maze{
            start: {1, 1},
            start_dir: :east,
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
            start_dir: :east,
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
            start_dir: :east,
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
            start_dir: :east,
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
        exp_start_mazes: [
          %Maze{
            start: {1, 3},
            start_dir: :south,
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
            start: {2, 3},
            start_dir: :south,
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
            start: {3, 3},
            start_dir: :west,
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
            start: {3, 2},
            start_dir: :west,
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
            start: {3, 1},
            start_dir: :north,
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
        ],
      ]
    end

    test "parser gets expected mazes (puzzle examples)", fixture do
      act_mazes = fixture.inputs
                  |> Enum.map(&parse_input_string/1)
      assert act_mazes == fixture.exp_mazes
    end

    test "parser gets expected mazes (moved-start examples)", fixture do
      act_start_mazes = fixture.start_inputs
                        |> Enum.map(&parse_input_string/1)
      assert act_start_mazes == fixture.exp_start_mazes
    end

    test "parser raises exception for invalid maze", fixture do
      [fixture.invalid_inputs, fixture.invalid_messages]
      |> Enum.zip()
      |> Enum.map(fn {input, message} ->
        assert_raise RuntimeError, message, fn ->
          parse_input_string(input)
        end
      end)
    end
  end
end
