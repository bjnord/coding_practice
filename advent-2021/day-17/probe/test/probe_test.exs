defmodule ProbeTest do
  use ExUnit.Case
  doctest Probe

  describe "puzzle example" do
    setup do
      [
        input: "target area: x=20..30, y=-10..-5\n",
        shots: [{7, 2}, {6, 3}],
        exp_results: [
          {:hit, [{7, 2}, {13, 3}, {18, 3}, {22, 2}, {25, 0}, {27, -3}, {28, -7}]},
          {:hit, [{6, 3}, {11, 5}, {15, 6}, {18, 6}, {20, 5}, {21, 3}, {21, 0}, {21, -4}, {21, -9}]},
          {:hit, [{9, 0}, {17, -1}, {24, -3}, {30, -6}]},
          {:miss, [{17, -4}, {33, -9}, {48, -15}]},
        ],
        exp_max_height: 45,
      ]
    end

    test "shooter gets expected results", fixture do
      target = Probe.Parser.parse(fixture.input)
      [fixture.shots, fixture.exp_results]
      |> Enum.zip()
      |> Enum.each(fn {shot, exp_result} ->
        assert Probe.fire(shot, target) == exp_result
      end)
    end

    test "max height finder gets the expected max height", fixture do
      target = Probe.Parser.parse(fixture.input)
      assert Probe.max_height(target) == fixture.exp_max_height
    end
  end
end
