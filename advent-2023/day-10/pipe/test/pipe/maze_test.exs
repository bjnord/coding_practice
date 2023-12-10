defmodule Pipe.MazeTest do
  use ExUnit.Case
  doctest Pipe.Maze, import: true

  alias Pipe.Maze

  describe "puzzle example" do
    setup do
      [
        mazes: [
        ],
        exp_steps: [],
      ]
    end

    test "find steps", fixture do
      act_steps = fixture.mazes
                  |> Enum.map(&Maze.steps/1)
      assert act_steps == fixture.exp_steps
    end
  end
end
