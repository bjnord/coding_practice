defmodule Snailfish.ParserTest do
  use ExUnit.Case
  doctest Snailfish.Parser

  alias Snailfish.Parser, as: Parser

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
        exp_tokenized_numbers: [
          [:o, :o, :o, 0, :s, :o, 5, :s, 8, :c, :c, :s, :o, :o, 1, :s, 7, :c, :s, :o, 9, :s, 6, :c, :c, :c, :s, :o, :o, 4, :s, :o, 1, :s, 2, :c, :c, :s, :o, :o, 1, :s, 4, :c, :s, 2, :c, :c, :c],
          [:o, :o, :o, 5, :s, :o, 2, :s, 8, :c, :c, :s, 4, :c, :s, :o, 5, :s, :o, :o, 9, :s, 9, :c, :s, 0, :c, :c, :c],
          [:o, 6, :s, :o, :o, :o, 6, :s, 2, :c, :s, :o, 5, :s, 6, :c, :c, :s, :o, :o, 7, :s, 6, :c, :s, :o, 4, :s, 7, :c, :c, :c, :c],
          [:o, :o, :o, 6, :s, :o, 0, :s, 7, :c, :c, :s, :o, 0, :s, 9, :c, :c, :s, :o, 4, :s, :o, 9, :s, :o, 9, :s, 0, :c, :c, :c, :c],
          [:o, :o, :o, 7, :s, :o, 6, :s, 4, :c, :c, :s, :o, 3, :s, :o, 1, :s, 3, :c, :c, :c, :s, :o, :o, :o, 5, :s, 5, :c, :s, 1, :c, :s, 9, :c, :c],
          [:o, :o, 6, :s, :o, :o, 7, :s, 3, :c, :s, :o, 3, :s, 2, :c, :c, :c, :s, :o, :o, :o, 3, :s, 8, :c, :s, :o, 5, :s, 7, :c, :c, :s, 4, :c, :c],
          [:o, :o, :o, :o, 5, :s, 4, :c, :s, :o, 7, :s, 7, :c, :c, :s, 8, :c, :s, :o, :o, 8, :s, 3, :c, :s, 8, :c, :c],
          [:o, :o, 9, :s, 3, :c, :s, :o, :o, 9, :s, 9, :c, :s, :o, 6, :s, :o, 4, :s, 9, :c, :c, :c, :c],
          [:o, :o, 2, :s, :o, :o, 7, :s, 7, :c, :s, 7, :c, :c, :s, :o, :o, 5, :s, 8, :c, :s, :o, :o, 9, :s, 3, :c, :s, :o, 0, :s, 2, :c, :c, :c, :c],
          [:o, :o, :o, :o, 5, :s, 2, :c, :s, 5, :c, :s, :o, 8, :s, :o, 3, :s, 7, :c, :c, :c, :s, :o, :o, 5, :s, :o, 7, :s, 5, :c, :c, :s, :o, 4, :s, 4, :c, :c, :c],
        ],
        # TODO move to Snailfish.Math
        exp_sum: "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]",
        exp_mag: 4140,
      ]
    end

    test "to_tokens() produces expected tokens", fixture do
      act_tokenized_numbers =
        fixture.input
        |> String.split("\n", trim: true)
        |> Enum.map(&Parser.to_tokens/1)
      assert act_tokenized_numbers == fixture.exp_tokenized_numbers
    end

    test "to_string() produces expected string", fixture do
      exp_string_numbers =
        fixture.input
        |> String.split("\n", trim: true)
      act_string_numbers =
        fixture.exp_tokenized_numbers
        |> Enum.map(&Parser.to_string/1)
      assert act_string_numbers == exp_string_numbers
    end
  end
end
