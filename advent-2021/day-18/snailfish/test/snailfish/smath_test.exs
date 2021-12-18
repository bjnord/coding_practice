defmodule Snailfish.SmathTest do
  use ExUnit.Case
  doctest Snailfish.Smath

  alias Snailfish.Smath, as: Smath

  describe "puzzle example" do
    setup do
      [
        input: """
        [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
        [[[5,[2,8]],4],[5,[[9,9],0]]]
        [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
        [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
        [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
        [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
        [[[[5,4],[7,7]],8],[[8,3],8]]
        [[9,3],[[9,9],[6,[4,9]]]]
        [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
        [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
        """,
        exp_homework_sum: "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]",
        exp_homework_mag: 4140,
        nored_sum_numbers: ["[1,1]", "[2,2]", "[3,3]", "[4,4]"],
        exp_nored_sum: "[[[[1,1],[2,2]],[3,3]],[4,4]]",
      ]
    end

    test "add() produces expected sums (no-reduction example)", fixture do
      assert Smath.add(fixture.nored_sum_numbers) == fixture.exp_nored_sum
    end
  end
end
