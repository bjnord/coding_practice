defmodule DiagnosticTest do
  use ExUnit.Case
  doctest Diagnostic

  describe "puzzle example" do
    setup do
      [
        entries: [
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 0],
          [1, 0, 1, 1, 0],
          [1, 0, 1, 1, 1],
          [1, 0, 1, 0, 1],
          [0, 1, 1, 1, 1],
          [0, 0, 1, 1, 1],
          [1, 1, 1, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 0, 0, 1],
          [0, 0, 0, 1, 0],
          [0, 1, 0, 1, 0],
        ],
        expected_part1: {22, 9},
        expected_part2: {23, 10},
      ]
    end

    test "gets expected part 1 rates", fixture do
      assert Diagnostic.compute_power_rates(fixture.entries) == fixture.expected_part1
    end

    test "gets expected part 2 ratings", fixture do
      assert Diagnostic.compute_life_support_ratings(fixture.entries) == fixture.expected_part2
    end
  end
end
