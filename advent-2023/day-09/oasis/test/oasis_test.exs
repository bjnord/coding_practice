defmodule OasisTest do
  use ExUnit.Case
  doctest Oasis, import: true

  describe "puzzle example" do
    setup do
      [
        entries: [
          [0, 3, 6, 9, 12, 15],
          [1, 3, 6, 10, 15, 21],
          [10, 13, 16, 21, 30, 45],
        ],
        exp_differences: [
          [3, 3, 3, 3, 3],
          [2, 3, 4, 5, 6],
          [3, 3, 5, 9, 15],
        ],
        exp_predicted: [
          18,
          28,
          68,
        ],
        exp_predicted_prev: 5,
      ]
    end

    test "find difference lines (part 1)", fixture do
      act_differences = fixture.entries
                        |> Enum.map(fn entry -> Oasis.calc_differences(entry, :forward) end)
      assert act_differences == fixture.exp_differences
    end

    test "find next predicted values (part 1)", fixture do
      act_predicted = fixture.entries
                      |> Enum.map(&Oasis.predicted/1)
      assert act_predicted == fixture.exp_predicted
    end

    test "find next predicted values with neg offset (part 1)", fixture do
      offset = 12
      offset_entries =
        fixture.entries
        |> Enum.map(fn entry ->
          Enum.map(entry, fn n -> n - offset end)
        end)
      act_predicted = offset_entries
                      |> Enum.map(&Oasis.predicted/1)
      offset_predicted = fixture.exp_predicted
                         |> Enum.map(fn n -> n - offset end)
      assert act_predicted == offset_predicted
    end

    test "find previous predicted value (part 2)", fixture do
      act_predicted = Enum.at(fixture.entries, -1)
                      |> Oasis.prev_predicted()
      assert act_predicted == fixture.exp_predicted_prev
    end
  end
end
