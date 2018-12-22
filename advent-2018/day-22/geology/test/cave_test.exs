defmodule CaveTest do
  use ExUnit.Case
  doctest Cave

  test "cave mapper" do
    fast_cave = Cave.new(510, {10, 10})
                |> Cave.cache_erosion({0..15, 0..15})
    assert Cave.map(fast_cave, {0..15, 0..15}) == [
      "M=.|=.|.|=.|=|=.",
      ".|=|=|||..|.=...",
      ".==|....||=..|==",
      "=.|....|.==.|==.",
      "=|..==...=.|==..",
      "=||.=.=||=|=..|=",
      "|.=.===|||..=..|",
      "|..==||=.|==|===",
      ".=..===..=|.|||.",
      ".======|||=|=.|=",
      ".===|=|===T===||",
      "=|||...|==..|=.|",
      "=.=|=.=..=.||==|",
      "||=|=...|==.=|==",
      "|=.=||===.|||===",
      "||.|==.|.|.||=||",
    ]
  end

  test "cost of move to neighbor (tool switched)" do
    cave = Cave.new(510, {10, 10})
    # {0, 1} is :wet
    assert Cave.neighbor_move_cost(cave, 1, :torch, :rocky, {0, 1}) == {9, :gear}
    # {1, 1} is :narrow
    assert Cave.neighbor_move_cost(cave, 9, :gear, :wet, {1, 1}) == {17, :nothing}
    # {1, 0} is :rocky
    assert Cave.neighbor_move_cost(cave, 17, :nothing, :narrow, {1, 0}) == {25, :torch}
  end

  test "cost of move to neighbor (no switch)" do
    cave = Cave.new(510, {10, 10})
    # {1, 0} is :rocky
    assert Cave.neighbor_move_cost(cave, 1, :torch, :rocky, {1, 0}) == {2, :torch}
    # {1, 1} is :narrow
    assert Cave.neighbor_move_cost(cave, 2, :torch, :rocky, {1, 1}) == {3, :torch}
    # {1, 2} is :wet
    assert Cave.neighbor_move_cost(cave, 3, :nothing, :narrow, {1, 2}) == {4, :nothing}
    # {0, 2} is :rocky
    assert Cave.neighbor_move_cost(cave, 4, :gear, :wet, {0, 2}) == {5, :gear}
  end

  test "cost of move to neighbor (solid rock = invalid)" do
    cave = Cave.new(510, {10, 10})
    assert Cave.neighbor_move_cost(cave, 1, :torch, :rocky, {-1, 0}) == {nil, nil}
    assert Cave.neighbor_move_cost(cave, 1, :torch, :rocky, {0, -1}) == {nil, nil}
  end

  test "cost of move to neighbor (target)" do
    cave = Cave.new(510, {10, 10})
    # {10, 10} is :rocky
    assert Cave.neighbor_move_cost(cave, 30, :torch, :rocky, {10, 10}) == {31, :torch}
    assert Cave.neighbor_move_cost(cave, 30, :gear, :wet, {10, 10}) == {38, :torch}
    assert Cave.neighbor_move_cost(cave, 30, :nothing, :narrow, {10, 10}) == {38, :torch}
  end
end
