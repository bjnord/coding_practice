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
  end
end
