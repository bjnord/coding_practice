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
  end
end
