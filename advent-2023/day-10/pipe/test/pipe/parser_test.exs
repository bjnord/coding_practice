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
        part2_inputs: [
          """
          ...........
          .S-------7.
          .|F-----7|.
          .||.....||.
          .||.....||.
          .|L-7.F-J|.
          .|..|.|..|.
          .L--J.L--J.
          ...........
          """,
          """
          .F----7F7F7F7F-7....
          .|F--7||||||||FJ....
          .||.FJ||||||||L7....
          FJL7L7LJLJ||LJ.L-7..
          L--J.L7...LJS7F-7L7.
          ....F-J..F7FJ|L7L7L7
          ....L7.F7||L7|.L7L7|
          .....|FJLJ|FJ|F7|.LJ
          ....FJL-7.||.||||...
          ....L---J.LJ.LJLJ...
          """,
          """
          FF7FSF7F7F7F7F7F---7
          L|LJ||||||||||||F--J
          FL-7LJLJ||||||LJL-77
          F--JF--7||LJLJ7F7FJ-
          L---JF-JLJ.||-FJLJJ7
          |F|F-JF---7F7-L7L|7|
          |FFJF7L7F-JF7|JL---7
          7-L-JL7||F7|L7F-7F7|
          L.L7LFJ|||||FJL7||LJ
          L7JLJL-JLJLJL--JLJ.L
          """,
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
        exp_part2_mazes: [
          %Maze{
            start: {1, 1},
            start_dir: :east,
            tiles: %{
              {5, 9} => ?|,
              {1, 2} => ?-,
              {5, 2} => ?L,
              {2, 4} => ?-,
              {4, 8} => ?|,
              {1, 1} => ?F,
              {3, 2} => ?|,
              {7, 3} => ?-,
              {7, 9} => ?J,
              {3, 1} => ?|,
              {6, 1} => ?|,
              {2, 7} => ?-,
              {7, 2} => ?-,
              {5, 8} => ?J,
              {7, 6} => ?L,
              {2, 8} => ?7,
              {1, 4} => ?-,
              {5, 6} => ?F,
              {6, 6} => ?|,
              {1, 7} => ?-,
              {4, 2} => ?|,
              {2, 3} => ?-,
              {1, 8} => ?-,
              {2, 1} => ?|,
              {7, 8} => ?-,
              {4, 9} => ?|,
              {7, 7} => ?-,
              {7, 1} => ?L,
              {5, 3} => ?-,
              {1, 6} => ?-,
              {4, 1} => ?|,
              {1, 9} => ?7,
              {6, 4} => ?|,
              {2, 6} => ?-,
              {1, 5} => ?-,
              {5, 1} => ?|,
              {2, 5} => ?-,
              {2, 2} => ?F,
              {5, 7} => ?-,
              {6, 9} => ?|,
              {7, 4} => ?J,
              {3, 8} => ?|,
              {5, 4} => ?7,
              {1, 3} => ?-,
              {3, 9} => ?|,
              {2, 9} => ?|,
            },
          },
          %Maze{
            start: {4, 12},
            start_dir: :east,
            tiles: %{
              {4, 5} => ?L,
              {6, 18} => ?7,
              {5, 9} => ?F,
              {3, 15} => ?L,
              {5, 17} => ?7,
              {3, 16} => ?-,
              {1, 2} => ?F,
              {8, 5} => ?J,
              {4, 15} => ?-,
              {4, 18} => ?7,
              {0, 9} => ?F,
              {8, 6} => ?L,
              {8, 11} => ?|,
              {8, 10} => ?|,
              {3, 6} => ?L,
              {3, 17} => ?7,
              {3, 12} => ?L,
              {6, 15} => ?L,
              {7, 16} => ?|,
              {2, 4} => ?F,
              {4, 12} => ?F,
              {6, 5} => ?7,
              {8, 14} => ?|,
              {0, 3} => ?-,
              {1, 1} => ?|,
              {9, 11} => ?J,
              {9, 6} => ?-,
              {4, 3} => ?J,
              {3, 7} => ?J,
              {9, 13} => ?L,
              {5, 10} => ?7,
              {0, 5} => ?-,
              {6, 10} => ?|,
              {0, 1} => ?F,
              {4, 0} => ?L,
              {7, 19} => ?J,
              {3, 2} => ?L,
              {9, 8} => ?J,
              {2, 13} => ?|,
              {7, 9} => ?J,
              {0, 8} => ?7,
              {7, 15} => ?7,
              {4, 13} => ?7,
              {3, 1} => ?J,
              {5, 16} => ?L,
              {2, 11} => ?|,
              {8, 4} => ?F,
              {7, 18} => ?L,
              {2, 7} => ?|,
              {4, 6} => ?7,
              {9, 4} => ?L,
              {6, 17} => ?L,
              {0, 7} => ?F,
              {2, 10} => ?|,
              {3, 11} => ?|,
              {4, 11} => ?J,
              {4, 10} => ?L,
              {8, 7} => ?-,
              {7, 6} => ?F,
              {0, 10} => ?7,
              {2, 8} => ?|,
              {1, 4} => ?-,
              {6, 19} => ?|,
              {5, 6} => ?J,
              {9, 5} => ?-,
              {1, 11} => ?|,
              {5, 11} => ?F,
              {4, 14} => ?F,
              {0, 4} => ?-,
              {5, 19} => ?7,
              {9, 16} => ?J,
              {6, 8} => ?7,
              {1, 7} => ?|,
              {4, 2} => ?-,
              {8, 8} => ?7,
              {2, 15} => ?7,
              {1, 8} => ?|,
              {3, 4} => ?L,
              {7, 5} => ?|,
              {1, 15} => ?J,
              {2, 1} => ?|,
              {4, 16} => ?7,
              {5, 13} => ?|,
              {3, 10} => ?|,
              {1, 14} => ?F,
              {7, 8} => ?L,
              {9, 14} => ?J,
              {3, 3} => ?7,
              {1, 10} => ?|,
              {3, 0} => ?F,
              {7, 11} => ?F,
              {9, 15} => ?L,
              {6, 13} => ?|,
              {6, 16} => ?7,
              {7, 7} => ?J,
              {8, 16} => ?|,
              {9, 10} => ?L,
              {8, 13} => ?|,
              {1, 6} => ?|,
              {4, 1} => ?-,
              {5, 5} => ?-,
              {6, 12} => ?7,
              {5, 14} => ?L,
              {7, 14} => ?F,
              {7, 12} => ?J,
              {1, 9} => ?|,
              {1, 12} => ?|,
              {6, 4} => ?L,
              {3, 5} => ?7,
              {2, 14} => ?L,
              {5, 18} => ?L,
              {3, 13} => ?J,
              {0, 15} => ?7,
              {0, 11} => ?F,
              {1, 13} => ?|,
              {2, 6} => ?|,
              {1, 5} => ?7,
              {2, 12} => ?|,
              {9, 7} => ?-,
              {7, 10} => ?|,
              {6, 11} => ?L,
              {2, 5} => ?J,
              {0, 13} => ?F,
              {8, 15} => ?|,
              {2, 2} => ?|,
              {6, 9} => ?|,
              {0, 2} => ?-,
              {0, 6} => ?7,
              {6, 7} => ?F,
              {0, 12} => ?7,
              {3, 8} => ?L,
              {5, 12} => ?J,
              {0, 14} => ?-,
              {7, 13} => ?|,
              {5, 4} => ?F,
              {4, 17} => ?L,
              {1, 3} => ?-,
              {3, 9} => ?J,
              {5, 15} => ?7,
              {2, 9} => ?|,
            },
          },
          %Maze{
            start: {0, 4},
            start_dir: :south,
            tiles: %{
              {4, 5} => ?F,
              {6, 18} => ?-,
              {5, 9} => ?-,
              {3, 15} => ?F,
              {4, 19} => ?7,
              {5, 17} => ?|,
              {3, 16} => ?7,
              {1, 2} => ?L,
              {8, 5} => ?F,
              {4, 15} => ?J,
              {4, 18} => ?J,
              {3, 18} => ?J,
              {0, 9} => ?F,
              {7, 17} => ?F,
              {8, 6} => ?J,
              {8, 11} => ?|,
              {8, 10} => ?|,
              {5, 2} => ?|,
              {3, 6} => ?-,
              {2, 16} => ?L,
              {3, 17} => ?F,
              {3, 12} => ?L,
              {6, 15} => ?L,
              {7, 16} => ?7,
              {2, 4} => ?L,
              {8, 17} => ?|,
              {4, 8} => ?L,
              {4, 12} => ?|,
              {6, 5} => ?7,
              {8, 14} => ?L,
              {0, 3} => ?F,
              {1, 1} => ?|,
              {9, 11} => ?J,
              {9, 6} => ?-,
              {4, 3} => ?-,
              {3, 7} => ?7,
              {9, 13} => ?-,
              {5, 0} => ?|,
              {5, 10} => ?7,
              {0, 5} => ?F,
              {6, 10} => ?J,
              {0, 1} => ?F,
              {1, 16} => ?F,
              {8, 9} => ?|,
              {8, 19} => ?J,
              {4, 0} => ?L,
              {3, 14} => ?7,
              {7, 19} => ?|,
              {3, 2} => ?-,
              {9, 8} => ?L,
              {2, 13} => ?|,
              {7, 3} => ?-,
              {7, 9} => ?F,
              {0, 8} => ?7,
              {7, 15} => ?-,
              {4, 13} => ?-,
              {3, 1} => ?-,
              {6, 1} => ?F,
              {5, 16} => ?L,
              {2, 0} => ?F,
              {2, 11} => ?|,
              {8, 3} => ?7,
              {8, 4} => ?L,
              {8, 12} => ?F,
              {7, 18} => ?7,
              {2, 7} => ?J,
              {4, 6} => ?-,
              {9, 4} => ?J,
              {6, 17} => ?-,
              {6, 2} => ?F,
              {0, 7} => ?F,
              {0, 16} => ?-,
              {9, 0} => ?L,
              {7, 2} => ?L,
              {2, 10} => ?|,
              {3, 11} => ?J,
              {4, 11} => ?|,
              {9, 19} => ?L,
              {0, 0} => ?F,
              {8, 7} => ?|,
              {5, 8} => ?-,
              {7, 6} => ?7,
              {0, 10} => ?7,
              {2, 8} => ?|,
              {1, 4} => ?|,
              {6, 19} => ?7,
              {2, 17} => ?-,
              {5, 6} => ?F,
              {9, 5} => ?L,
              {1, 11} => ?|,
              {6, 6} => ?L,
              {5, 11} => ?F,
              {4, 14} => ?F,
              {9, 3} => ?L,
              {0, 4} => ?7,
              {5, 19} => ?|,
              {9, 16} => ?L,
              {6, 8} => ?F,
              {1, 7} => ?|,
              {4, 2} => ?-,
              {2, 19} => ?7,
              {1, 19} => ?J,
              {8, 8} => ?|,
              {2, 15} => ?J,
              {2, 3} => ?7,
              {1, 8} => ?|,
              {8, 2} => ?L,
              {3, 4} => ?F,
              {7, 5} => ?L,
              {1, 15} => ?|,
              {2, 1} => ?L,
              {4, 16} => ?L,
              {3, 19} => ?-,
              {5, 13} => ?-,
              {7, 0} => ?7,
              {3, 10} => ?L,
              {1, 14} => ?|,
              {7, 8} => ?|,
              {9, 14} => ?-,
              {4, 7} => ?J,
              {3, 3} => ?J,
              {1, 10} => ?|,
              {3, 0} => ?F,
              {6, 14} => ?J,
              {7, 11} => ?|,
              {4, 9} => ?J,
              {9, 15} => ?J,
              {6, 13} => ?|,
              {9, 1} => ?7,
              {6, 16} => ?-,
              {7, 7} => ?|,
              {0, 17} => ?-,
              {6, 0} => ?|,
              {8, 16} => ?|,
              {7, 1} => ?-,
              {9, 10} => ?L,
              {5, 3} => ?F,
              {8, 13} => ?J,
              {8, 18} => ?L,
              {0, 19} => ?7,
              {1, 6} => ?|,
              {4, 1} => ?-,
              {5, 5} => ?J,
              {6, 12} => ?7,
              {5, 14} => ?L,
              {7, 14} => ?F,
              {7, 12} => ?L,
              {8, 0} => ?L,
              {1, 9} => ?|,
              {1, 12} => ?|,
              {9, 2} => ?J,
              {6, 4} => ?F,
              {1, 17} => ?-,
              {3, 5} => ?-,
              {1, 0} => ?L,
              {2, 14} => ?L,
              {5, 18} => ?7,
              {3, 13} => ?J,
              {0, 15} => ?F,
              {0, 11} => ?F,
              {1, 13} => ?|,
              {2, 6} => ?L,
              {1, 5} => ?|,
              {2, 12} => ?|,
              {1, 18} => ?-,
              {9, 7} => ?J,
              {7, 10} => ?7,
              {5, 1} => ?F,
              {2, 18} => ?7,
              {6, 11} => ?F,
              {2, 5} => ?J,
              {0, 13} => ?F,
              {8, 15} => ?7,
              {2, 2} => ?-,
              {5, 7} => ?-,
              {6, 9} => ?-,
              {0, 2} => ?7,
              {9, 12} => ?L,
              {4, 4} => ?J,
              {7, 4} => ?J,
              {0, 6} => ?7,
              {6, 7} => ?7,
              {0, 12} => ?7,
              {3, 8} => ?|,
              {0, 18} => ?-,
              {9, 17} => ?J,
              {5, 12} => ?7,
              {6, 3} => ?J,
              {0, 14} => ?7,
              {7, 13} => ?7,
              {5, 4} => ?-,
              {4, 17} => ?J,
              {1, 3} => ?J,
              {9, 9} => ?J,
              {3, 9} => ?|,
              {5, 15} => ?7,
              {2, 9} => ?|,
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

    test "parser gets expected mazes (part 2 examples)", fixture do
      act_part2_mazes = fixture.part2_inputs
                        |> Enum.map(&parse_input_string/1)
      assert act_part2_mazes == fixture.exp_part2_mazes
    end
  end
end
