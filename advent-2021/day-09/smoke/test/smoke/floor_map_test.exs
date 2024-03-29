defmodule Smoke.FloorMapTest do
  use ExUnit.Case
  doctest Smoke.FloorMap

  describe "puzzle example" do
    setup do
      [
        locations: [
          [2, 1, 9, 9, 9, 4, 3, 2, 1, 0], 
          [3, 9, 8, 7, 8, 9, 4, 9, 2, 1], 
          [9, 8, 5, 6, 7, 8, 9, 8, 9, 2], 
          [8, 7, 6, 7, 8, 9, 6, 7, 8, 9], 
          [9, 8, 9, 9, 9, 6, 5, 6, 7, 8], 
        ],
        exp_map: %{
          {0, 0} => 2, {1, 0} => 1, {2, 0} => 9, {3, 0} => 9, {4, 0} => 9,
          {5, 0} => 4, {6, 0} => 3, {7, 0} => 2, {8, 0} => 1, {9, 0} => 0,
          {0, 1} => 3, {1, 1} => 9, {2, 1} => 8, {3, 1} => 7, {4, 1} => 8,
          {5, 1} => 9, {6, 1} => 4, {7, 1} => 9, {8, 1} => 2, {9, 1} => 1,
          {0, 2} => 9, {1, 2} => 8, {2, 2} => 5, {3, 2} => 6, {4, 2} => 7,
          {5, 2} => 8, {6, 2} => 9, {7, 2} => 8, {8, 2} => 9, {9, 2} => 2,
          {0, 3} => 8, {1, 3} => 7, {2, 3} => 6, {3, 3} => 7, {4, 3} => 8,
          {5, 3} => 9, {6, 3} => 6, {7, 3} => 7, {8, 3} => 8, {9, 3} => 9,
          {0, 4} => 9, {1, 4} => 8, {2, 4} => 9, {3, 4} => 9, {4, 4} => 9,
          {5, 4} => 6, {6, 4} => 5, {7, 4} => 6, {8, 4} => 7, {9, 4} => 8,
        },
        exp_low_points: [
          {{1, 0}, 1},
          {{2, 2}, 5},
          {{6, 4}, 5},
          {{9, 0}, 0},
        ],
        exp_risk_level_sum: 15,
        exp_basin_locations: %{
          {1, 0} => [{0, 0}, {1, 0}, {0, 1}],
          {2, 2} => [
            {2, 1}, {3, 1}, {4, 1},
            {1, 2}, {2, 2}, {3, 2}, {4, 2}, {5, 2},
            {0, 3}, {1, 3}, {2, 3}, {3, 3}, {4, 3},
            {1, 4},
          ],
          {9, 0} => [
            {5, 0}, {6, 0}, {7, 0}, {8, 0}, {9, 0},
            {6, 1}, {8, 1}, {9, 1},
            {9, 2},
          ],
          {6, 4} => [
            {7, 2},
            {6, 3}, {7, 3}, {8, 3},
            {5, 4}, {6, 4}, {7, 4}, {8, 4}, {9, 4},
          ],
        },
        exp_largest_3_basin_counts: [14, 9, 9],
      ]
    end

    test "map has expected locations", fixture do
      assert fixture.locations |> Smoke.FloorMap.build_floor_map() == fixture.exp_map
    end

    test "map produces expected low points", fixture do
      act_low_points =
        fixture.exp_map
        |> Smoke.FloorMap.low_points()
        |> Enum.sort()
      assert act_low_points == fixture.exp_low_points
    end

    test "map produces expected risk level sum", fixture do
      assert fixture.exp_low_points |> Smoke.FloorMap.risk_level_sum() == fixture.exp_risk_level_sum
    end

    test "map produces expected basin locations", fixture do
      Map.keys(fixture.exp_basin_locations)
      |> Enum.each(fn k ->
        act_basin_locations =
          fixture.exp_map
          |> Smoke.FloorMap.basin_locations(k)
          |> elem(1)
          |> Enum.sort()
        assert act_basin_locations == Enum.sort(fixture.exp_basin_locations[k])
      end)
    end

    test "map produces location counts for the largest 3 basins", fixture do
      act_counts = Smoke.FloorMap.largest_3_basin_counts(fixture.exp_map)
      assert act_counts == fixture.exp_largest_3_basin_counts
    end
  end
end
