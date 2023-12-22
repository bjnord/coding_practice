defmodule Sand.BrickTest do
  use ExUnit.Case
  doctest Sand.Brick, import: true

  alias Sand.Brick

  describe "puzzle example" do
    setup do
      [
        bricks: [
          %Brick{n: 1, from: %{x: 1, y: 0, z: 1}, to: %{x: 1, y: 2, z: 1}},  # A
          %Brick{n: 2, from: %{x: 0, y: 0, z: 2}, to: %{x: 2, y: 0, z: 2}},  # B
          %Brick{n: 3, from: %{x: 0, y: 2, z: 3}, to: %{x: 2, y: 2, z: 3}},  # C
          %Brick{n: 4, from: %{x: 0, y: 0, z: 4}, to: %{x: 0, y: 2, z: 4}},  # D
          %Brick{n: 5, from: %{x: 2, y: 0, z: 5}, to: %{x: 2, y: 2, z: 5}},  # E
          %Brick{n: 6, from: %{x: 0, y: 1, z: 6}, to: %{x: 2, y: 1, z: 6}},  # F
          %Brick{n: 7, from: %{x: 1, y: 1, z: 8}, to: %{x: 1, y: 1, z: 9}},  # G
        ],
        exp_dropped_bricks: [
          %Brick{n: 1, from: %{x: 1, y: 0, z: 1}, to: %{x: 1, y: 2, z: 1}, supported_by: []},
          %Brick{n: 2, from: %{x: 0, y: 0, z: 2}, to: %{x: 2, y: 0, z: 2}, supported_by: [1]},
          %Brick{n: 3, from: %{x: 0, y: 2, z: 2}, to: %{x: 2, y: 2, z: 2}, supported_by: [1]},
          %Brick{n: 4, from: %{x: 0, y: 0, z: 3}, to: %{x: 0, y: 2, z: 3}, supported_by: [3, 2]},
          %Brick{n: 5, from: %{x: 2, y: 0, z: 3}, to: %{x: 2, y: 2, z: 3}, supported_by: [3, 2]},
          %Brick{n: 6, from: %{x: 0, y: 1, z: 4}, to: %{x: 2, y: 1, z: 4}, supported_by: [5, 4]},
          %Brick{n: 7, from: %{x: 1, y: 1, z: 5}, to: %{x: 1, y: 1, z: 6}, supported_by: [6]},
        ],
        exp_supports: %{
          1 => [3, 2],
          2 => [5, 4],
          3 => [5, 4],
          4 => [6],
          5 => [6],
          6 => [7],
          7 => [],
        },
        exp_disintegratable: [2, 3, 4, 5, 7],
      ]
    end

    test "find new brick positions after drop", fixture do
      act_dropped_bricks =
        fixture.bricks
        |> Brick.drop()
      assert act_dropped_bricks == fixture.exp_dropped_bricks
    end

    test "find bricks supported by", fixture do
      act_supports =
        fixture.exp_dropped_bricks
        |> Brick.supports()
      assert act_supports == fixture.exp_supports
    end

    test "find disintegratable bricks", fixture do
      act_disintegratable =
        fixture.exp_dropped_bricks
        |> Brick.disintegratable()
      assert act_disintegratable == fixture.exp_disintegratable
    end
  end
end
