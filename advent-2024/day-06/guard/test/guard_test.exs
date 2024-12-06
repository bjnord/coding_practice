defmodule GuardTest do
  use ExUnit.Case
  doctest Guard

  alias Xmas.Grid

  describe "puzzle example" do
    setup do
      [
        grid: %Grid{
          size: %{y: 10, x: 10},
          squares: %{
            {0, 4} => ?#, {1, 9} => ?#, {3, 2} => ?#, {4, 7} => ?#,
            {6, 1} => ?#, {7, 8} => ?#, {8, 0} => ?#, {9, 6} => ?#,
            {6, 4} => ?^,
          },
        },
        exp_path_length: 41,
        loop_grid: %Grid{
          size: %{y: 10, x: 10},
          squares: %{
            {0, 4} => ?#, {1, 9} => ?#, {3, 2} => ?#, {4, 7} => ?#,
            {6, 1} => ?#, {7, 8} => ?#, {8, 0} => ?#, {9, 6} => ?#,
            {6, 4} => ?^, {7, 7} => ?#,
          },
        },
        exp_loop_obstacles: [
          {6, 3},
          {7, 6},
          {7, 7},
          {8, 1},
          {8, 3},
          {9, 7},
        ]
      ]
    end

    test "predicts correct guard path length", fixture do
      act_path_length = fixture.grid
                        |> Guard.path_length()
      assert act_path_length == fixture.exp_path_length
    end

    test "detects looping", fixture do
      act_path_length = fixture.loop_grid
                        |> Guard.path_length()
      assert act_path_length == :loop
    end

    test "finds potential loop-producing obstacles", fixture do
      act_loopstacles = fixture.grid
                        |> Guard.loop_obstacles()
                        |> Enum.sort()
      assert act_loopstacles == fixture.exp_loop_obstacles
    end
  end
end
