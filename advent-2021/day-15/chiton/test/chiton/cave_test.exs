defmodule Chiton.CaveTest do
  use ExUnit.Case
  doctest Chiton.Cave

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
        input3: """
        116
        138
        213
        """,
        exp_cave3: %Chiton.Cave{
          dimx: 3,
          dimy: 3,
          risks: {
            {1, 1, 6},
            {1, 3, 8},
            {2, 1, 3},
          },
          dist: %{{0, 0} => 0},
          unvisited: [
            {0, 0}, {1, 0}, {2, 0},
            {0, 1}, {1, 1}, {2, 1},
            {0, 2}, {1, 2}, {2, 2},
          ],
          pqueue: {1, {0, {0, 0}, nil, nil}},
        },
        exp_distances3: %{
          {0, 0} => 0, {1, 0} => 1, {2, 0} => 7,
          {0, 1} => 1, {1, 1} => 4, {2, 1} => 12,
          {0, 2} => 3, {1, 2} => 4, {2, 2} => 7,
        },
      ]
    end

    test "parser gets expected cave struct", fixture do
      assert Chiton.Cave.new(fixture.input3) == fixture.exp_cave3
    end

    test "Dijkstra finds expected shortest paths (risk levels)", fixture do
      act_distances =
        fixture.exp_cave3
        |> Chiton.Cave.distances()
      assert act_distances == fixture.exp_distances3
    end

    test "Dijkstra finds expected minimum-risk path (input)", fixture do
      act_min_risk =
        fixture.input
        |> Chiton.Cave.new()
        |> Chiton.Cave.min_total_risk()
      assert act_min_risk == fixture.exp_min_risk
    end
  end
end
