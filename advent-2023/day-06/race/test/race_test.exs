defmodule RaceTest do
  use ExUnit.Case
  doctest Race

  describe "puzzle example" do
    setup do
      [
        races: [
          {7, 9},
          {15, 40},
          {30, 200},
        ],
        exp_race_1_distances: [
          0,
          6,
          10,
          12,
          12,
          10,
          6,
          0,
        ],
        exp_n_wins: [
          4,
          8,
          9,
        ],
      ]
    end

    test "calculate race 1 distances", fixture do
      act_distances = fixture.races
                      |> List.first()
                      |> elem(0)
                      |> Race.distances()
      assert act_distances == fixture.exp_race_1_distances
    end

    test "calculate number of race wins", fixture do
      act_n_wins = fixture.races
                   |> Enum.map(&Race.n_wins/1)
      assert act_n_wins == fixture.exp_n_wins
    end
  end
end
