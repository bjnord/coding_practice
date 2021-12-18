defmodule Snailfish.SmathTest do
  use ExUnit.Case
  doctest Snailfish.Smath

  alias Snailfish.Parser, as: Parser
  alias Snailfish.Smath, as: Smath

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
        exp_homework_largest_mag: 3993,
        sum_numbers: [
          ["[[[[4,3],4],4],[7,[[8,4],9]]]", "[1,1]"],
          ["[1,1]", "[2,2]", "[3,3]", "[4,4]"],
          ["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]"],
          ["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]", "[6,6]"],
        ],
        exp_sums: [
          "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]",
          "[[[[1,1],[2,2]],[3,3]],[4,4]]",
          "[[[[3,0],[5,3]],[4,4]],[5,5]]",
          "[[[[5,0],[7,4]],[5,5]],[6,6]]",
        ],
        sum_larger_numbers: [
          "[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]",
          "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]",
          "[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]",
          "[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]",
          "[7,[5,[[3,8],[1,4]]]]",
          "[[2,[2,2]],[8,[8,1]]]",
          "[2,9]",
          "[1,[[[9,3],9],[[9,0],[0,7]]]]",
          "[[[5,[7,4]],7],1]",
          "[[[[4,2],2],6],[8,7]]",
        ],
        exp_larger_sums: [
          "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]",
          "[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]",
          "[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]",
          "[[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]",
          "[[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]",
          "[[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]",
          "[[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]",
          "[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]",
          "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]",
        ],
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
        magnitude_tests: [
          {"[1,9]", 21},
          {"[[1,2],[[3,4],5]]", 143},
          {"[[[[0,7],4],[[7,8],[6,0]]],[8,1]]", 1384},
          {"[[[[1,1],[2,2]],[3,3]],[4,4]]", 445},
          {"[[[[3,0],[5,3]],[4,4]],[5,5]]", 791},
          {"[[[[5,0],[7,4]],[5,5]],[6,6]]", 1137},
          {"[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]", 3488},
        ],
      ]
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

    test "add() produces expected sum", fixture do
      [fixture.sum_numbers, fixture.exp_sums]
      |> Enum.zip()
      |> Enum.each(fn {numbers, exp_sum} ->
        assert Smath.add(numbers) == exp_sum
      end)
    end

    test "add() produces expected sum at each step (larger example)", fixture do
      [acc | sum_numbers] = fixture.sum_larger_numbers
      [sum_numbers, fixture.exp_larger_sums]
      |> Enum.zip()
      |> Enum.reduce(acc, fn ({number, exp_sum}, acc) ->
        acc = Smath.add([acc, number])
        assert acc == exp_sum
        acc
      end)
    end

    test "add() produces expected sum (homework example)", fixture do
      homework_numbers = String.split(fixture.homework, "\n", trim: true)
      [acc | numbers] = homework_numbers
      act_sum =
        numbers
        |> Enum.reduce(acc, fn (number, acc) ->
          Smath.add([acc, number])
        end)
      assert act_sum == fixture.exp_homework_sum
    end

    test "magnitude() produces expected magnitude", fixture do
      fixture.magnitude_tests
      |> Enum.each(fn {number, exp_magnitude} ->
        assert Smath.magnitude(number) == exp_magnitude
      end)
    end

    test "largest_magnitude() produces expected magnitude", fixture do
      act_homework_largest_mag =
        fixture.homework
        |> String.split("\n", trim: true)
        |> Snailfish.largest_magnitude()
      assert act_homework_largest_mag == fixture.exp_homework_largest_mag
    end
  end
end
