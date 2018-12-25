defmodule NanobotTest do
  use ExUnit.Case
  doctest Nanobot

  import Nanobot

  test "intersection" do
    n1 = {{10, 12, 12}, 2}
    n2 = {{12, 14, 12}, 2}
    assert intersect?(n1, n2) == true

    n3 = {{10, 10, 10}, 5}
    assert intersect?(n2, n3) == false
  end

  test "intersection (barely touching coordinates)" do
    n1 = {{2, 12, 22}, 3}
    n2 = {{4, 14, 24}, 3}
    assert intersect?(n1, n2) == true
  end

  test "intersection (barely separate coordinates)" do
    n1_point = {2, 12, 22}
    n2 = {{4, 14, 25}, 3}
    assert intersect?(n1_point, n2) == false
  end

  test "point-intersection" do
    n1 = {{10, 12, 12}, 5}
    n2_point = {11, 11, 11}
    assert intersect?(n2_point, n1) == true

    n3 = {{9, 9, 9}, 5}
    assert intersect?(n2_point, n3) == false
  end

  test "point-intersection (barely touching coordinates)" do
    n1_point = {2, 12, 22}
    n2 = {{4, 14, 24}, 6}
    assert intersect?(n1_point, n2) == true
  end

  test "point-intersection (barely separate coordinates)" do
    n1_point = {2, 12, 22}
    n2 = {{4, 14, 25}, 6}
    assert intersect?(n1_point, n2) == false
  end

  test "intersection ranges (coordinates)" do
    n1 = {{10, 12, 12}, 2}  # 8..12, 10..14, 10..14
    n2 = {{12, 14, 12}, 2}  # 10..14, 12..16, 10..14
    assert intersection_ranges(n1, n2) == {10..12, 12..14, 10..14}

    n3 = {{18, 18, 18}, 5}  # 13..23, 13..23, 13..23
    assert intersection_ranges(n1, n3) == nil
    assert intersection_ranges(n2, n3) == {13..14, 13..16, 13..14}
  end

  test "intersection ranges (barely touching coordinates)" do
    n1 = {{2, 12, 22}, 1}  # 1..3, 11..13, 21..23
    n2 = {{4, 14, 24}, 1}  # 3..5, 13..15, 23..25
    assert intersection_ranges(n1, n2) == {3..3, 13..13, 23..23}
  end

  test "intersection ranges (barely separate coordinates)" do
    n1 = {{2, 12, 22}, 1}  # 1..3, 11..13, 21..23
    n2 = {{4, 14, 25}, 1}  # 3..5, 13..15, 24..26
    assert intersection_ranges(n1, n2) == nil
  end

  test "intersection ranges (ranges)" do
    n1 = {8..12, 10..14, 10..14}
    n2 = {10..14, 12..16, 10..14}
    assert intersection_ranges(n1, n2) == {10..12, 12..14, 10..14}

    n3 = {5..9, 15..15, 5..15}
    assert intersection_ranges(n1, n3) == nil
    assert intersection_ranges(n2, n3) == nil
  end

  test "Manhattan distance 3-D" do
    assert manhattan({1, 3, 2}, {4, 1, 5}) == 3 + 2 + 3
  end
end
