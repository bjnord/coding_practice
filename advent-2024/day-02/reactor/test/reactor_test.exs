defmodule ReactorTest do
  use ExUnit.Case
  doctest Reactor

  alias Reactor

  describe "puzzle example" do
    setup do
      [
        reports: [
          [7, 6, 4, 2, 1],
          [1, 2, 7, 8, 9],
          [9, 7, 6, 2, 1],
          [1, 3, 2, 4, 5],
          [8, 6, 4, 4, 1],
          [1, 3, 6, 7, 9],
        ],
        # h/t <https://www.reddit.com/r/adventofcode/comments/1h4shdu/2024_day_2_part2_edge_case_finder/>
        edge_cases: [
         [48, 46, 47, 49, 51, 54, 56],
         [1, 1, 2, 3, 4, 5],
         [1, 2, 3, 4, 5, 5],
         [5, 1, 2, 3, 4, 5],
         [1, 4, 3, 2, 1],
         [1, 6, 7, 8, 9],
         [1, 2, 3, 4, 3],
         [9, 8, 7, 6, 7],
         [7, 10, 8, 10, 11],
         [29, 28, 27, 25, 26, 25, 22, 20],
        ],
        exp_analyses: [
          :safe,
          :unsafe,
          :unsafe,
          :unsafe,
          :unsafe,
          :safe,
        ],
        exp_dampener_analyses: [
          :safe,
          :unsafe,
          :unsafe,
          :safe,
          :safe,
          :safe,
        ],
      ]
    end

    test "produces expected analyses", fixture do
      act_analyses = fixture.reports
                     |> Enum.map(&Reactor.analyze_safety/1)
      assert act_analyses == fixture.exp_analyses
    end

    test "produces expected analyses with dampener", fixture do
      act_dampener_analyses =
        fixture.reports
        |> Enum.map(&Reactor.analyze_safety_with_dampener/1)
      assert act_dampener_analyses == fixture.exp_dampener_analyses
    end

    test "produces expected analyses with dampener (edge cases)", fixture do
      act_dampener_analyses =
        fixture.edge_cases
        |> Enum.map(&Reactor.analyze_safety_with_dampener/1)
      assert Enum.all?(act_dampener_analyses, &(&1 == :safe))
    end
  end
end
