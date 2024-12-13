defmodule GuardTest do
  use ExUnit.Case
  doctest Guard

  alias History.Grid

  describe "puzzle example" do
    setup do
      [
        grid: %Grid{
          size: %{y: 10, x: 10},
          squares: %{
            {0, 4} => ?#, {1, 9} => ?#, {3, 2} => ?#, {4, 7} => ?#,
            {6, 1} => ?#, {7, 8} => ?#, {8, 0} => ?#, {9, 6} => ?#,
          },
          meta: %{start: {6, 4}},
        },
        exp_squares_walked: 41,
        loop_grid: %Grid{
          size: %{y: 10, x: 10},
          squares: %{
            {0, 4} => ?#, {1, 9} => ?#, {3, 2} => ?#, {4, 7} => ?#,
            {6, 1} => ?#, {7, 8} => ?#, {8, 0} => ?#, {9, 6} => ?#,
            {7, 7} => ?#,
          },
          meta: %{start: {6, 4}},
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

    test "calculates unique squares walked", fixture do
      act_squares_walked = fixture.grid
                           |> Guard.squares_walked()
      assert act_squares_walked == fixture.exp_squares_walked
    end

    test "detects looping", fixture do
      act_squares_walked = fixture.loop_grid
                           |> Guard.squares_walked()
      assert act_squares_walked == :loop
    end

    test "finds potential loop-producing obstacles", fixture do
      act_loopstacles = fixture.grid
                        |> Guard.loop_obstacles()
                        |> Enum.sort()
      assert act_loopstacles == fixture.exp_loop_obstacles
    end
  end
end
