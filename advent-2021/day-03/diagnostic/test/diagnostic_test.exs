defmodule DiagnosticTest do
  use ExUnit.Case
  doctest Diagnostic

  describe "example for part 1" do
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
        expected: {22, 9},
      ]
    end

    test "gets expected sum", fixture do
      assert Diagnostic.compute_power_rates(fixture.entries) == fixture.expected
    end
  end
end
