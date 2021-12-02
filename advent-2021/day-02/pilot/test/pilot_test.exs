defmodule PilotTest do
  use ExUnit.Case
  doctest Pilot

  describe "example for part 1" do
    setup do
      [
        steps: [{5, 0}, {0, 5}, {8, 0}, {0, -3}, {0, 8}, {2, 0}],
        expected: {15, 10},
      ]
    end

    test "gets expected sum", fixture do
      assert Pilot.navigate_naïvely(fixture.steps) == fixture.expected
    end
  end
end
