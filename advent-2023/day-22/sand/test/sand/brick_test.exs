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
        exp_dropped_positions: [
          %Brick{n: 1, from: %{x: 1, y: 0, z: 1}, to: %{x: 1, y: 2, z: 1}},  # A
          %Brick{n: 2, from: %{x: 0, y: 0, z: 2}, to: %{x: 2, y: 0, z: 2}},  # B
          %Brick{n: 3, from: %{x: 0, y: 2, z: 2}, to: %{x: 2, y: 2, z: 2}},  # C
          %Brick{n: 4, from: %{x: 0, y: 0, z: 3}, to: %{x: 0, y: 2, z: 3}},  # D
          %Brick{n: 5, from: %{x: 2, y: 0, z: 3}, to: %{x: 2, y: 2, z: 3}},  # E
          %Brick{n: 6, from: %{x: 0, y: 1, z: 4}, to: %{x: 2, y: 1, z: 4}},  # F
          %Brick{n: 7, from: %{x: 1, y: 1, z: 5}, to: %{x: 1, y: 1, z: 6}},  # G
        ],
      ]
    end

    test "find new brick positions after drop", fixture do
      act_dropped_positions =
        fixture.bricks
        |> Brick.drop()
      assert act_dropped_positions == fixture.exp_dropped_positions
    end
  end
end
