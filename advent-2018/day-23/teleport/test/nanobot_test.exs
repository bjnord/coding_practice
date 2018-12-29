defmodule NanobotTest do
  use ExUnit.Case
  doctest Nanobot

  import Nanobot

  test "in range (enclosed low)" do
    space = {3..33, 13..43, 23..53}
    nanobot1 = {{6, 16, 26}, 3}
    nanobot2 = {{7, 17, 27}, 3}
    assert in_range_of?(nanobot1, space) == true
    assert in_range_of?(nanobot2, space) == true
  end

  test "in range (enclosed high)" do
    space = {3..33, 13..43, 23..53}
    nanobot1 = {{30, 40, 50}, 3}
    nanobot2 = {{29, 39, 49}, 3}
    assert in_range_of?(nanobot1, space) == true
    assert in_range_of?(nanobot2, space) == true
  end

  test "in range (barely touching low)" do
    space = {3..33, 13..43, 23..53}
    nanobot1 = {{2, 12, 22}, 3}
    nanobot2 = {{0, 13, 23}, 3}
    assert in_range_of?(nanobot1, space) == true
    assert in_range_of?(nanobot2, space) == true
  end

  test "in range (barely touching high)" do
    space = {3..33, 13..43, 23..53}
    nanobot1 = {{34, 44, 54}, 3}
    nanobot2 = {{33, 43, 56}, 3}
    assert in_range_of?(nanobot1, space) == true
    assert in_range_of?(nanobot2, space) == true
  end

  test "in range (barely separate low)" do
    space = {3..33, 13..43, 23..53}
    nanobot1 = {{2, 12, 22}, 2}
    nanobot2 = {{3, 10, 23}, 2}
    assert in_range_of?(nanobot1, space) == false
    assert in_range_of?(nanobot2, space) == false
  end

  test "in range (barely separate high)" do
    space = {3..33, 13..43, 23..53}
    nanobot1 = {{34, 44, 54}, 2}
    nanobot2 = {{36, 43, 53}, 2}
    assert in_range_of?(nanobot1, space) == false
    assert in_range_of?(nanobot2, space) == false
  end

  test "in range (engulfing)" do
    space = {3..3, 13..13, 23..23}
    nanobot1 = {{2, 12, 22}, 3}
    nanobot2 = {{4, 14, 24}, 3}
    assert in_range_of?(nanobot1, space) == true
    assert in_range_of?(nanobot2, space) == true
  end

  test "in range (center)" do
    space = {3..33, 13..43, 23..53}
    nanobot = {{18, 28, 38}, 3}
    assert in_range_of?(nanobot, space) == true
  end

  test "in range count (example1)" do
    bots = [
      {{0, 0, 0}, 4},
      {{1, 0, 0}, 1},
      {{4, 0, 0}, 3},
      {{0, 2, 0}, 1},
      {{0, 5, 0}, 3},  # no
      {{0, 0, 3}, 1},  # no
      {{1, 1, 1}, 1},
      {{1, 1, 2}, 1},
      {{1, 3, 1}, 1},  # no
    ]
    assert in_range_count(bots, {0..1, 0..1, 0..1}) == 6
  end

  test "in range count (example2)" do
    bots = [
      {{10, 12, 12}, 2},
      {{12, 14, 12}, 2},
      {{16, 12, 12}, 4},
      {{14, 14, 14}, 6},
      {{50, 50, 50}, 200},
      {{10, 10, 10}, 5},
    ]
    assert in_range_count(bots, {12..12, 12..12, 12..12}) == 5
    assert in_range_count(bots, {30..50, 30..50, 30..50}) == 1
    assert in_range_count(bots, {100..150, 150..200, 100..150}) == 1
    assert in_range_count(bots, {100..150, 150..200, 101..151}) == 0
  end

  test "space distance to origin" do
    assert space_distance_to_0({12..14, 12..16, 14..16}) == 12 + 12 + 14
    assert space_distance_to_0({3..33, 13..43, 23..53}) == 3 + 13 + 23
  end

  test "space size" do
    assert space_size({12..12, 12..12, 12..12}) == 1
    assert space_size({12..14, 12..16, 14..16}) == 3 * 5 * 3
    assert space_size({3..33, 13..43, 23..53}) == 31 * 31 * 31
  end

  test "space partitions" do
    assert space_partitions({3..33, 13..43, 23..53}) == [
      {3..18, 13..28, 23..38},
      {3..18, 13..28, 38..53},
      {3..18, 28..43, 23..38},
      {3..18, 28..43, 38..53},
      {18..33, 13..28, 23..38},
      {18..33, 13..28, 38..53},
      {18..33, 28..43, 23..38},
      {18..33, 28..43, 38..53},
    ]
    assert space_partitions({3..33, 28..28, 23..53}) == [
      {3..18, 28..28, 23..38},
      {3..18, 28..28, 38..53},
      {18..33, 28..28, 23..38},
      {18..33, 28..28, 38..53},
    ]
    assert space_partitions({12..12, 12..12, 12..12}) ==
      [{12..12, 12..12, 12..12}]
  end

  test "space partitions (edge case)" do
    assert space_partitions({11..12, 11..12, 11..12}) == [
      {11..11, 11..11, 11..11},
      {11..11, 11..11, 12..12},
      {11..11, 12..12, 11..11},
      {11..11, 12..12, 12..12},
      {12..12, 11..11, 11..11},
      {12..12, 11..11, 12..12},
      {12..12, 12..12, 11..11},
      {12..12, 12..12, 12..12},
    ]
  end

  test "encompassing space (example1)" do
    bots = [
      {{0, 0, 0}, 4}, # x=-4 y=-4 z=-4
      {{1, 0, 0}, 1},
      {{4, 0, 0}, 3}, # x=7
      {{0, 2, 0}, 1},
      {{0, 5, 0}, 3}, # y=8
      {{0, 0, 3}, 1}, # z=4
      {{1, 1, 1}, 1},
      {{1, 1, 2}, 1},
      {{1, 3, 1}, 1},
    ]
    assert encompassing_space(bots) == {-4..7, -4..8, -4..4}
  end

  test "encompassing space (example2)" do
    bots = [
      {{10, 12, 12}, 2},
      {{12, 14, 12}, 2},
      {{16, 12, 12}, 4},
      {{14, 14, 14}, 6},
      {{50, 50, 50}, 200},
      {{10, 10, 10}, 5},
    ]
    assert encompassing_space(bots) == {-150..250, -150..250, -150..250}
  end

  test "Manhattan distance 3-D" do
    assert manhattan({1, 3, 2}, {4, 1, 5}) == 3 + 2 + 3
  end
end
