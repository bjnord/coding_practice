defmodule Snailfish.SmathTest do
  use ExUnit.Case
  doctest Snailfish.Smath

  alias Snailfish.Parser, as: Parser
  alias Snailfish.Smath, as: Smath

  # [TODO turn this into a test that checks intermediate steps]
  # Here's a slightly larger example:
  #
  # [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
  # [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
  # [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
  # [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
  # [7,[5,[[3,8],[1,4]]]]
  # [[2,[2,2]],[8,[8,1]]]
  # [2,9]
  # [1,[[[9,3],9],[[9,0],[0,7]]]]
  # [[[5,[7,4]],7],1]
  # [[[[4,2],2],6],[8,7]]
  #
  # The final sum [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]] is found after adding up the above snailfish numbers:
  #
  #   [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
  # + [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
  # = [[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]
  #
  #   [[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]
  # + [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
  # = [[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]
  #
  #   [[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]
  # + [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
  # = [[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]
  #
  #   [[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]
  # + [7,[5,[[3,8],[1,4]]]]
  # = [[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]
  #
  #   [[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]
  # + [[2,[2,2]],[8,[8,1]]]
  # = [[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]
  #
  #   [[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]
  # + [2,9]
  # = [[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]
  #
  #   [[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]
  # + [1,[[[9,3],9],[[9,0],[0,7]]]]
  # = [[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]
  #
  #   [[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]
  # + [[[5,[7,4]],7],1]
  # = [[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]
  #
  #   [[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]
  # + [[[[4,2],2],6],[8,7]]
  # = [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]

  describe "puzzle example" do
    setup do
      [
        homework: """
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
        # TODO move this to sum_numbers:
        nored_sum_numbers: ["[1,1]", "[2,2]", "[3,3]", "[4,4]"],
        exp_nored_sum: "[[[[1,1],[2,2]],[3,3]],[4,4]]",
        sum_numbers: [
          ["[[[[4,3],4],4],[7,[[8,4],9]]]", "[1,1]"],
          ["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]"],
          ["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]", "[6,6]"],
        ],
        exp_sums: [
          "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]",
          "[[[[3,0],[5,3]],[4,4]],[5,5]]",
          "[[[[5,0],[7,4]],[5,5]],[6,6]]",
        ],
        # TODO this one is temporary:
        reduce_split_test: {
          [:o, :o, :o, :o, 0, :s, 7, :c, :s, 4, :c, :s, :o, 15, :s, :o, 0, :s, 13, :c, :c, :c, :s, :o, 1, :s, 1, :c, :c],
          "[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]",
        },
        nonexplodable_number: "[7,[6,[5,[4,3]]]]",
        # in this one, the 5th brace isn't a simple pair:
        tricky_explodable_number: "[[3,[2,[[1,[7,3]],6]]],[5,[4,[3,2]]]]",
        explodable_numbers: [
          "[[[[[9,8],1],2],3],4]",
          "[7,[6,[5,[4,[3,2]]]]]",
          "[[6,[5,[4,[3,2]]]],1]",
          "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]",
          "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]",
        ],
        exp_tricky_context: {11, 9, 18},
        exp_exploded_contexts: [
          {4, nil, 10},
          {12, 10, nil},
          {10, 8, 19},
          {10, 8, 20},
          {24, 22, nil},
        ],
        exp_exploded_numbers: [
          "[[[[0,9],2],3],4]",
          "[7,[6,[5,[7,0]]]]",
          "[[6,[5,[7,0]]],3]",
          "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]",
          "[[3,[2,[8,0]]],[9,[5,[7,0]]]]",
        ],
      ]
    end

    # TODO this one is temporary (see "move this" above):
    test "add() produces expected sums (no-reduction example)", fixture do
      assert Smath.add(fixture.nored_sum_numbers) == fixture.exp_nored_sum
    end

    # TODO this one is temporary:
    test "reduce() produces expected reduction (split-only example)", fixture do
      {tokens, exp_reduction} = fixture.reduce_split_test
      assert Smath.reduce(tokens) == exp_reduction
    end

    test "find_explodable_context() produces expected contexts", fixture do
      act_contexts =
        [fixture.nonexplodable_number, fixture.tricky_explodable_number | fixture.explodable_numbers]
        |> Enum.map(&Parser.to_tokens/1)
        |> Enum.map(&Smath.find_explodable_context/1)
      exp_contexts = [nil, fixture.exp_tricky_context | fixture.exp_exploded_contexts]
      assert act_contexts == exp_contexts
    end

    test "explode_at() produces expected exploded number (no-split examples)", fixture do
      act_numbers =
        fixture.explodable_numbers
        |> Enum.map(&Parser.to_tokens/1)
        |> Enum.map(&({&1, Smath.find_explodable_context(&1)}))
        |> Enum.map(fn {tokens, context} -> Smath.explode_at(tokens, context) end)
        |> Enum.map(&Parser.to_string/1)
      assert act_numbers == fixture.exp_exploded_numbers
    end

    # TODO test that sum_numbers produces exp_sums

    # TODO test "slightly larger example" here

    # TODO test that homework produces exp_homework_sum & exp_homework_sum
  end
end
