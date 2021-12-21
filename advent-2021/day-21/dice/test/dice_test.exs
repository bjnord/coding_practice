defmodule DiceTest do
  use ExUnit.Case
  doctest Dice

  describe "puzzle example" do
    setup do
      [
        start_positions: {4, 8},
        exp_part1_answer: 739785,
      ]
    end

    test "player gets expected part 1 answer", fixture do
      act_answer =
        Dice.play(fixture.start_positions)
        |> Tuple.delete_at(3)
        |> Tuple.delete_at(1)
        |> IO.inspect(label: "scores and turns")
        |> Dice.part1_answer()
      assert act_answer == fixture.exp_part1_answer
    end
  end
end
