defmodule History.MathTest do
  use ExUnit.Case
  doctest History.Math

  # no AoC year is complete without...:
  test "Manhattan distance (3D)" do
    pos1 = {1105, -1205, 1229}
    pos2 = {-92, -2380, -20}
    assert History.Math.manhattan(pos1, pos2) == 3621
  end
  test "Manhattan distance (2D)" do
    pos1 = {1105, -1205}
    pos2 = {-92, -2380}
    assert History.Math.manhattan(pos1, pos2) == 2372
  end

  test "pairings" do
    entries = [:a, :b, :c, :d]
    pairings = [
      {:a, :b}, {:a, :c}, {:a, :d},
      {:b, :c}, {:b, :d},
      {:c, :d}
    ]
    assert History.Math.pairings(entries) == pairings
    assert History.Math.pairings([:z]) == []
    assert History.Math.pairings([]) == []
  end
end
