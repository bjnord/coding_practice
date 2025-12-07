defmodule LiftTest do
  use ExUnit.Case
  doctest Lift

  describe "puzzle example" do
    setup do
      [
        banks: [
          ~c"987654321111111",
          ~c"811111111111119",
          ~c"234234234234278",
          ~c"818181911112111",
        ],
        exp_max_joltages_2: [
          98,
          89,
          78,
          92,
        ],
        exp_max_joltages_12: [
          987654321111,
          811111111119,
          434234234278,
          888911112111,
        ],
      ]
    end

    test "computes expected max joltages for 2 batteries", fixture do
      act_max_joltages_2 =
        fixture.banks
        |> Enum.map(&Lift.max_joltage/1)
      assert act_max_joltages_2 == fixture.exp_max_joltages_2
    end

    test "computes expected max joltages for 12 batteries", fixture do
      act_max_joltages_12 =
        fixture.banks
        |> Enum.map(fn bank -> Lift.max_joltage(bank, 12) end)
      assert act_max_joltages_12 == fixture.exp_max_joltages_12
    end
  end
end
