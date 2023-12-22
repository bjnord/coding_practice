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
        double_bricks: [
          %Brick{n:  1, from: %{x: 1, y: 0, z:  1}, to: %{x: 1, y: 2, z:  1}},
          %Brick{n:  2, from: %{x: 0, y: 0, z:  2}, to: %{x: 2, y: 0, z:  2}},
          %Brick{n:  3, from: %{x: 0, y: 2, z:  3}, to: %{x: 2, y: 2, z:  3}},
          %Brick{n:  4, from: %{x: 0, y: 0, z:  4}, to: %{x: 0, y: 2, z:  4}},
          %Brick{n:  5, from: %{x: 2, y: 0, z:  5}, to: %{x: 2, y: 2, z:  5}},
          %Brick{n:  6, from: %{x: 0, y: 1, z:  6}, to: %{x: 2, y: 1, z:  6}},
          %Brick{n:  7, from: %{x: 1, y: 1, z:  8}, to: %{x: 1, y: 1, z:  9}},
          %Brick{n:  8, from: %{x: 1, y: 0, z: 11}, to: %{x: 1, y: 2, z: 11}},
          %Brick{n:  9, from: %{x: 0, y: 0, z: 12}, to: %{x: 2, y: 0, z: 12}},
          %Brick{n: 10, from: %{x: 0, y: 2, z: 13}, to: %{x: 2, y: 2, z: 13}},
          %Brick{n: 11, from: %{x: 0, y: 0, z: 14}, to: %{x: 0, y: 2, z: 14}},
          %Brick{n: 12, from: %{x: 2, y: 0, z: 15}, to: %{x: 2, y: 2, z: 15}},
          %Brick{n: 13, from: %{x: 0, y: 1, z: 16}, to: %{x: 2, y: 1, z: 16}},
          %Brick{n: 14, from: %{x: 1, y: 1, z: 18}, to: %{x: 1, y: 1, z: 19}},
        ],
        exp_dropped_double_bricks: [
          %Brick{n:  1, from: %{x: 1, y: 0, z:  1}, to: %{x: 1, y: 2, z:  1}, supported_by: []},
          %Brick{n:  2, from: %{x: 0, y: 0, z:  2}, to: %{x: 2, y: 0, z:  2}, supported_by: [1]},
          %Brick{n:  3, from: %{x: 0, y: 2, z:  2}, to: %{x: 2, y: 2, z:  2}, supported_by: [1]},
          %Brick{n:  4, from: %{x: 0, y: 0, z:  3}, to: %{x: 0, y: 2, z:  3}, supported_by: [3, 2]},
          %Brick{n:  5, from: %{x: 2, y: 0, z:  3}, to: %{x: 2, y: 2, z:  3}, supported_by: [3, 2]},
          %Brick{n:  6, from: %{x: 0, y: 1, z:  4}, to: %{x: 2, y: 1, z:  4}, supported_by: [5, 4]},
          %Brick{n:  7, from: %{x: 1, y: 1, z:  5}, to: %{x: 1, y: 1, z:  6}, supported_by: [6]},
          %Brick{n:  8, from: %{x: 1, y: 0, z:  7}, to: %{x: 1, y: 2, z:  7}, supported_by: [7]},
          %Brick{n:  9, from: %{x: 0, y: 0, z:  8}, to: %{x: 2, y: 0, z:  8}, supported_by: [8]},
          %Brick{n: 10, from: %{x: 0, y: 2, z:  8}, to: %{x: 2, y: 2, z:  8}, supported_by: [8]},
          %Brick{n: 11, from: %{x: 0, y: 0, z:  9}, to: %{x: 0, y: 2, z:  9}, supported_by: [10, 9]},
          %Brick{n: 12, from: %{x: 2, y: 0, z:  9}, to: %{x: 2, y: 2, z:  9}, supported_by: [10, 9]},
          %Brick{n: 13, from: %{x: 0, y: 1, z: 10}, to: %{x: 2, y: 1, z: 10}, supported_by: [12, 11]},
          %Brick{n: 14, from: %{x: 1, y: 1, z: 11}, to: %{x: 1, y: 1, z: 12}, supported_by: [13]},
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
        exp_double_supports: %{
           1 => [3, 2],
           2 => [5, 4],
           3 => [5, 4],
           4 => [6],
           5 => [6],
           6 => [7],
           7 => [8],
           8 => [10, 9],
           9 => [12, 11],
          10 => [12, 11],
          11 => [13],
          12 => [13],
          13 => [14],
          14 => [],
        },
        exp_disintegratable: [2, 3, 4, 5, 7],
        exp_chain_disint_counts: [
          {1, 6},
          {6, 1},
        ],
        exp_nonchain_disint_counts: [
          {1, 6},
          {6, 1},
        ],
        exp_double_chain_disint_counts: [
          { 1, 6 + 7},
          { 6, 1 + 7},
          { 7, 0 + 7},
          {13, 1},
          { 8, 1},
        ],
        exp_double_nonchain_disint_counts: [
          { 1, 6 + 7},
          { 6, 1 + 7},
          { 7, 0 + 7},
          { 8, 6},
          {13, 1},
        ],
      ]
    end

    test "find new brick positions after drop", fixture do
      act_dropped_bricks =
        fixture.bricks
        |> Brick.drop()
      assert act_dropped_bricks == fixture.exp_dropped_bricks
    end

    test "find new brick positions after drop (double example)", fixture do
      act_dropped_double_bricks =
        fixture.double_bricks
        |> Brick.drop()
      assert act_dropped_double_bricks == fixture.exp_dropped_double_bricks
    end

    test "find bricks supported by", fixture do
      act_supports =
        fixture.exp_dropped_bricks
        |> Brick.supports()
      assert act_supports == fixture.exp_supports
    end

    test "find bricks supported by (double example)", fixture do
      act_double_supports =
        fixture.exp_dropped_double_bricks
        |> Brick.supports()
      assert act_double_supports == fixture.exp_double_supports
    end

    test "find disintegratable bricks", fixture do
      act_disintegratable =
        fixture.exp_dropped_bricks
        |> Brick.disintegratable()
      assert act_disintegratable == fixture.exp_disintegratable
    end

    test "find chain disintegration counts", fixture do
      act_chain_disint_counts =
        fixture.exp_dropped_bricks
        |> Brick.chain_disintegration()
      assert act_chain_disint_counts == fixture.exp_chain_disint_counts
    end

    test "find chain disintegration counts (double example)", fixture do
      act_double_chain_disint_counts =
        fixture.exp_dropped_double_bricks
        |> Brick.chain_disintegration()
      assert act_double_chain_disint_counts == fixture.exp_double_chain_disint_counts
    end

    test "find non-chain disintegration counts", fixture do
      act_nonchain_disint_counts =
        fixture.exp_dropped_bricks
        |> Brick.nonchain_disintegration()
      assert act_nonchain_disint_counts == fixture.exp_nonchain_disint_counts
    end

    test "find non-chain disintegration counts (double example)", fixture do
      act_double_nonchain_disint_counts =
        fixture.exp_dropped_double_bricks
        |> Brick.nonchain_disintegration()
      assert act_double_nonchain_disint_counts == fixture.exp_double_nonchain_disint_counts
    end
  end
end
