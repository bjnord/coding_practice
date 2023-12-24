defmodule HailTest do
  use ExUnit.Case
  doctest Hail

  describe "puzzle example" do
    setup do
      [
        hailstones: [
          {{19, 13, 30}, {-2,  1, -2}},
          {{18, 19, 22}, {-1, -1, -2}},
          {{20, 25, 34}, {-2, -2, -4}},
          {{12, 31, 28}, {-1, -2, -1}},
          {{20, 19, 15}, { 1, -5, -3}},
        ],
      ]
    end

    # Hailstone A: 19, 13, 30 @ -2, 1, -2
    # Hailstone B: 18, 19, 22 @ -1, -1, -2
    # Hailstones' paths will cross inside the test area (at x=14.333, y=15.333).
    test "2D intersection of hailstones A and B", fixture do
      a = Enum.at(fixture.hailstones, 0)
      b = Enum.at(fixture.hailstones, 1)
      {act_x, act_y} = Hail.intersect_2d(a, b)
      assert_in_delta act_x, 14.333, 0.01
      assert_in_delta act_y, 15.333, 0.01
    end

    # Hailstone A: 19, 13, 30 @ -2, 1, -2
    # Hailstone C: 20, 25, 34 @ -2, -2, -4
    # Hailstones' paths will cross inside the test area (at x=11.667, y=16.667).
    test "2D intersection of hailstones A and C", fixture do
      a = Enum.at(fixture.hailstones, 0)
      c = Enum.at(fixture.hailstones, 2)
      {act_x, act_y} = Hail.intersect_2d(a, c)
      assert_in_delta act_x, 11.667, 0.01
      assert_in_delta act_y, 16.667, 0.01
    end

    # Hailstone A: 19, 13, 30 @ -2, 1, -2
    # Hailstone D: 12, 31, 28 @ -1, -2, -1
    # Hailstones' paths will cross outside the test area (at x=6.2, y=19.4).
    test "2D intersection of hailstones A and D", fixture do
      a = Enum.at(fixture.hailstones, 0)
      d = Enum.at(fixture.hailstones, 3)
      {act_x, act_y} = Hail.intersect_2d(a, d)
      assert_in_delta act_x, 6.2, 0.01
      assert_in_delta act_y, 19.4, 0.01
    end

    # Hailstone B: 18, 19, 22 @ -1, -1, -2
    # Hailstone C: 20, 25, 34 @ -2, -2, -4
    # Hailstones' paths are parallel; they never intersect.
    test "2D intersection of hailstones B and C", fixture do
      b = Enum.at(fixture.hailstones, 1)
      c = Enum.at(fixture.hailstones, 2)
      assert Hail.intersect_2d(b, c) == {nil, nil}
    end

    # Hailstone B: 18, 19, 22 @ -1, -1, -2
    # Hailstone D: 12, 31, 28 @ -1, -2, -1
    # Hailstones' paths will cross outside the test area (at x=-6, y=-5).
    test "2D intersection of hailstones B and D", fixture do
      b = Enum.at(fixture.hailstones, 1)
      d = Enum.at(fixture.hailstones, 3)
      {act_x, act_y} = Hail.intersect_2d(b, d)
      assert_in_delta act_x, -6.0, 0.01
      assert_in_delta act_y, -5.0, 0.01
    end

    # Hailstone C: 20, 25, 34 @ -2, -2, -4
    # Hailstone D: 12, 31, 28 @ -1, -2, -1
    # Hailstones' paths will cross outside the test area (at x=-2, y=3).
    test "2D intersection of hailstones C and D", fixture do
      c = Enum.at(fixture.hailstones, 2)
      d = Enum.at(fixture.hailstones, 3)
      {act_x, act_y} = Hail.intersect_2d(c, d)
      assert_in_delta act_x, -2.0, 0.01
      assert_in_delta act_y, 3.0, 0.01
    end
  end
end
