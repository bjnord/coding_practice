defmodule Chiton.CaveTest do
  use ExUnit.Case
  doctest Chiton.Cave

  alias Chiton.Cave, as: Cave

  describe "puzzle example" do
    setup do
      [
        input: """
        1163751742
        1381373672
        2136511328
        3694931569
        7463417111
        1319128137
        1359912421
        3125421639
        1293138521
        2311944581
        """,
        exp_min_risk: 40,
        exp_min_risk_scale5: 315,
        input3: """
        116
        138
        213
        """,
        exp_cave3: %Cave{
          dimx: 3,
          dimy: 3,
          scale: 1,
          risks: {
            {1, 1, 6},
            {1, 3, 8},
            {2, 1, 3},
          },
          dist: %{{0, 0} => 0},
          pqueue: {1, {0, {0, 0}, nil, nil}},
          visited: %MapSet{},
        },
        exp_distances3: %{
          {0, 0} => 0, {1, 0} => 1, {2, 0} => 7,
          {0, 1} => 1, {1, 1} => 4, {2, 1} => 12,
          {0, 2} => 3, {1, 2} => 4, {2, 2} => 7,
        },
        exp_cave3_scale3: %Cave{
          dimx: 3,
          dimy: 3,
          scale: 3,
          risks: {
            {1, 1, 6},
            {1, 7, 8},
            {2, 1, 3},
          },
          dist: %{{0, 0} => 0},
          pqueue: {1, {0, {0, 0}, nil, nil}},
          visited: %MapSet{},
        },
      ]
    end

    test "parser gets expected cave struct", fixture do
      assert Cave.new(fixture.input3) == fixture.exp_cave3
    end

    test "Dijkstra finds expected shortest paths (risk levels)", fixture do
      assert Cave.distances(fixture.exp_cave3) == fixture.exp_distances3
    end

    test "Dijkstra finds expected minimum-risk path (scale=1)", fixture do
      act_min_risk =
        fixture.input
        |> Cave.new()
        |> Cave.min_total_risk()
      assert act_min_risk == fixture.exp_min_risk
    end

    test "Dijkstra finds expected minimum-risk path (scale=5)", fixture do
      act_min_risk_scale5 =
        fixture.input
        |> Cave.new(scale: 5)
        |> Cave.min_total_risk()
      assert act_min_risk_scale5 == fixture.exp_min_risk_scale5
    end

    test "risk function does correct lookup (scale=1)", fixture do
      cave = fixture.exp_cave3
      [{{0, 0}, 1}, {{0, 2}, 2}, {{2, 2}, 3}, {{2, 0}, 6}, {{1, 1}, 3}, {{2, 1}, 8}]
      |> Enum.each(fn {pos, risk} ->
        assert Cave.risk_at(cave, pos) == risk
      end)
    end

    test "risk function does correct lookup (scale=3)", fixture do
      cave = fixture.exp_cave3_scale3
      [
        # tile 0,0
        {{0, 0}, 1}, {{0, 2}, 2}, {{2, 2}, 3}, {{2, 0}, 6}, {{1, 1}, 7}, {{2, 1}, 8},
        # tile 1,0
        {{3+0, 0}, 2}, {{3+0, 2}, 3}, {{3+2, 2}, 4}, {{3+2, 0}, 7}, {{3+1, 1}, 8}, {{3+2, 1}, 9},
        # tile 1,1
        {{3+0, 3+0}, 3}, {{3+0, 3+2}, 4}, {{3+2, 3+2}, 5}, {{3+2, 3+0}, 8}, {{3+1, 3+1}, 9}, {{3+2, 3+1}, 1},
        # tile 2,1
        {{6+0, 3+0}, 4}, {{6+0, 3+2}, 5}, {{6+2, 3+2}, 6}, {{6+2, 3+0}, 9}, {{6+1, 3+1}, 1}, {{6+2, 3+1}, 2},
        # tile 2,2
        {{6+0, 6+0}, 5}, {{6+0, 6+2}, 6}, {{6+2, 6+2}, 7}, {{6+2, 6+0}, 1}, {{6+1, 6+1}, 2}, {{6+2, 6+1}, 3},
      ]
      |> Enum.each(fn {{x, y}, risk} ->
        assert Cave.risk_at(cave, {x, y}) == risk
      end)
    end
  end
end
