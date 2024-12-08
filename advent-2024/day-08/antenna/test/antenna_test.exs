defmodule AntennaTest do
  use ExUnit.Case
  doctest Antenna

  describe "puzzle example" do
    setup do
      [
        antenna_chart: {
          [
            {{1, 8}, ?0},
            {{2, 5}, ?0},
            {{3, 7}, ?0},
            {{4, 4}, ?0},
            {{5, 6}, ?A},
            {{8, 8}, ?A},
            {{9, 9}, ?A},
          ],
          {12, 12},
        },
        exp_antenna_groups: %{
          ?0 => [
            {4, 4},
            {3, 7},
            {2, 5},
            {1, 8},
          ],
          ?A => [
            {9, 9},
            {8, 8},
            {5, 6},
          ],
        },
        exp_antenna_antinodes: [
          {0, 6}, {0, 11},
          {1, 3},
          {2, 4}, {2, 10},
          {3, 2},
          {4, 9},
          {5, 1}, {5, 6},
          {6, 3},
          {7, 0}, {7, 7},
          {10, 10},
          {11, 10},
        ],
      ]
    end

    test "antenna groupings", fixture do
      act_antenna_groups = fixture.antenna_chart
                           |> Antenna.groups()
      assert act_antenna_groups == fixture.exp_antenna_groups
    end

    test "antenna antinodes", fixture do
      act_antenna_antinodes = fixture.antenna_chart
                              |> Antenna.antinodes()
                              |> Enum.sort()
      assert act_antenna_antinodes == fixture.exp_antenna_antinodes
    end
  end
end
