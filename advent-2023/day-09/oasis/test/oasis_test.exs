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
        ]
      ]
    end

    test "find difference line", fixture do
      act_differences = fixture.entries
                        |> Enum.map(&Oasis.calc_differences/1)
      assert act_differences == fixture.exp_differences
    end

    test "find predicted value", fixture do
      act_predicted = fixture.entries
                      |> Enum.map(&Oasis.predicted/1)
      assert act_predicted == fixture.exp_predicted
    end
  end
end
