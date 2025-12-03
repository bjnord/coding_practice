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
          ~c"818181911112111"
        ],
        exp_max_joltages: [
          98,
          89,
          78,
          92,
        ],
      ]
    end

    test "computes expected max joltages", fixture do
      act_max_joltages = fixture.banks
                         |> Enum.map(&Lift.max_joltage/1)
      assert act_max_joltages == fixture.exp_max_joltages
    end
  end
end
