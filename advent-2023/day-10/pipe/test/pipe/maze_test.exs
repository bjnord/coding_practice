defmodule Pipe.MazeTest do
  use ExUnit.Case
  doctest Pipe.Maze, import: true

  alias Pipe.Maze

  describe "puzzle example" do
    setup do
      [
        mazes: [
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
        exp_steps: [4, 4, 8, 8],
        exp_walks: [
          [
            {1, 1},
            {1, 2},
            {1, 3},
            {2, 3},
            {3, 3},
            {3, 2},
            {3, 1},
            {2, 1},
          ],
          [
            {1, 1},
            {1, 2},
            {1, 3},
            {2, 3},
            {3, 3},
            {3, 2},
            {3, 1},
            {2, 1},
          ],
          [
            {2, 0},
            {2, 1},
            {1, 1},
            {1, 2},
            {0, 2},
            {0, 3},
            {1, 3},
            {2, 3},
            {2, 4},
            {3, 4},
            {3, 3},
            {3, 2},
            {3, 1},
            {4, 1},
            {4, 0},
            {3, 0},
          ],
          [
            {2, 0},
            {2, 1},
            {1, 1},
            {1, 2},
            {0, 2},
            {0, 3},
            {1, 3},
            {2, 3},
            {2, 4},
            {3, 4},
            {3, 3},
            {3, 2},
            {3, 1},
            {4, 1},
            {4, 0},
            {3, 0},
          ],
        ],
        exp_dimensions: [
          {4, 4},
          {5, 5},
          {5, 5},
          {5, 5},
        ],
      ]
    end

    test "find step counts", fixture do
      act_steps = fixture.mazes
                  |> Enum.map(&Maze.steps/1)
      assert act_steps == fixture.exp_steps
    end

    test "walk (find steps taken)", fixture do
      act_walks = fixture.mazes
                  |> Enum.map(&Maze.walk/1)
      assert act_walks == fixture.exp_walks
    end

    test "find dimensions", fixture do
      act_dimensions = fixture.mazes
                       |> Enum.map(&Maze.dimensions/1)
      assert act_dimensions == fixture.exp_dimensions
    end
  end
end
