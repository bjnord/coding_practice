defmodule CaveTest do
  use ExUnit.Case
  doctest Cave

  test "cheapest path (short paths)" do
    fast_cave = Cave.new(510, {10, 10}, 0)
                |> Cave.cache_erosion()
    assert Cave.cheapest_path(fast_cave, {0, 0}, :torch, {0, 2}) == 16  # 2 steps, 2 tool changes
    assert Cave.cheapest_path(fast_cave, {0, 0}, :torch, {3, 3}) == 20  # 6 steps, 2 tool changes
  end

  test "cheapest path (puzzle example)" do
    fast_cave = Cave.new(510, {10, 10}, 5)
                |> Cave.cache_erosion()
    assert Cave.cheapest_path(fast_cave, {0, 0}, :torch, {10, 10}) == 45
  end

  test "cave mapper" do
    fast_cave = Cave.new(510, {10, 10}, 5)
                |> Cave.cache_erosion()
    assert Cave.map(fast_cave, Cave.bounds_range(fast_cave)) == [
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

  test "banned tool?" do
    cave = Cave.new(510, {10, 10}, 0)
    # {0, 1} is :wet
    assert Cave.banned_tool?(cave, {{0, 1}, :torch}) == true  # "if it gets wet, you won't have a light source"
    assert Cave.banned_tool?(cave, {{0, 1}, :gear}) == false
    assert Cave.banned_tool?(cave, {{0, 1}, :nothing}) == false
    # {1, 1} is :narrow
    assert Cave.banned_tool?(cave, {{1, 1}, :torch}) == false
    assert Cave.banned_tool?(cave, {{1, 1}, :gear}) == true  # "it's too bulky to fit"
    assert Cave.banned_tool?(cave, {{1, 1}, :nothing}) == false
    # {1, 0} is :rocky
    assert Cave.banned_tool?(cave, {{1, 0}, :torch}) == false
    assert Cave.banned_tool?(cave, {{1, 0}, :gear}) == false
    assert Cave.banned_tool?(cave, {{1, 0}, :nothing}) == true  # "you'll likely slip and fall"
  end

  test "solid rock?" do
    cave = Cave.new(21, {3, 3}, 2, 1)
    assert Cave.solid_rock?(cave, {0, 0}) == false
    assert Cave.solid_rock?(cave, {-1, 0}) == true
    assert Cave.solid_rock?(cave, {0, -1}) == true
    assert Cave.solid_rock?(cave, {4, 5}) == false  # inside margins 
    assert Cave.solid_rock?(cave, {5, 5}) == true
    assert Cave.solid_rock?(cave, {4, 6}) == true
  end

  test "neighbor move cost" do
    cave = Cave.new(510, {10, 10}, 0)
    # {0, 0} is :rocky  {0, 1} is :wet  {1, 0} is :rocky
    assert Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{0, 0}, :gear}) == 7
    assert Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{0, 0}, :nothing}) == nil  # banned
    assert Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{0, -1}, :torch}) == nil  # solid rock
    assert Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{0, 1}, :torch}) == nil  # banned
    assert Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{-1, 0}, :torch}) == nil  # solid rock
    assert Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{1, 0}, :torch}) == 1
    # {0, 1} is :wet  {0, 0} is :rocky  {0, 2} is :rocky  {1, 1} is :narrow
    assert Cave.neighbor_cost(cave, 8, {{0, 1}, :gear}, {{0, 1}, :nothing}) == 15
    assert Cave.neighbor_cost(cave, 8, {{0, 1}, :gear}, {{0, 1}, :torch}) == nil  # banned
    assert Cave.neighbor_cost(cave, 8, {{0, 1}, :gear}, {{0, 0}, :gear}) == 9
    assert Cave.neighbor_cost(cave, 8, {{0, 1}, :gear}, {{0, 2}, :gear}) == 9
    assert Cave.neighbor_cost(cave, 8, {{0, 1}, :gear}, {{-1, 1}, :gear}) == nil  # solid rock
    assert Cave.neighbor_cost(cave, 8, {{0, 1}, :gear}, {{1, 1}, :gear}) == nil  # banned
    # {1, 1} is :narrow  {1, 0} is :rocky  {1, 2} is :wet  {0, 1} is :wet  {2, 1} is :wet
    assert Cave.neighbor_cost(cave, 16, {{1, 1}, :nothing}, {{1, 1}, :torch}) == 23
    assert Cave.neighbor_cost(cave, 16, {{1, 1}, :nothing}, {{1, 1}, :gear}) == nil  # banned
    assert Cave.neighbor_cost(cave, 16, {{1, 1}, :nothing}, {{1, 0}, :nothing}) == nil  # banned
    assert Cave.neighbor_cost(cave, 16, {{1, 1}, :nothing}, {{1, 2}, :nothing}) == 17
    assert Cave.neighbor_cost(cave, 16, {{1, 1}, :nothing}, {{0, 1}, :nothing}) == 17
    assert Cave.neighbor_cost(cave, 16, {{1, 1}, :nothing}, {{2, 1}, :nothing}) == 17
  end

  test "neighbor move cost (change more than one axis)" do
    cave = Cave.new(510, {10, 10}, 0)
    assert_raise ArgumentError, fn ->
      Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{0, 1}, :gear})  # x and tool
    end
    assert_raise ArgumentError, fn ->
      Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{1, 0}, :gear})  # y and tool
    end
    assert_raise ArgumentError, fn ->
      Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{1, 1}, :torch})  # y and x
    end
  end

  test "neighbor move cost (change nothing)" do
    cave = Cave.new(510, {10, 10}, 0)
    assert_raise ArgumentError, fn ->
      Cave.neighbor_cost(cave, 0, {{0, 0}, :torch}, {{0, 0}, :torch})
    end
  end
end
