defmodule Camel.ParserTest do
  use ExUnit.Case
  doctest Camel.Parser, import: true

  import Camel.Parser
  alias Camel.Hand

  describe "puzzle example" do
    setup do
      [
        samples: """
        AAAAA 666
        AA8AA 555
        23332 444
        TTT98 333
        23432 222
        A23A4 111
        23456 000
        """,
        exp_sample_hands: [
          %Hand{ cards: [14, 14, 14, 14, 14], bid: 666, type: :kind5, type_i: 6 },
          %Hand{ cards: [14, 14,  8, 14, 14], bid: 555, type: :kind4, type_i: 5 },
          %Hand{ cards: [ 2,  3,  3,  3,  2], bid: 444, type: :fullh, type_i: 4 },
          %Hand{ cards: [10, 10, 10,  9,  8], bid: 333, type: :kind3, type_i: 3 },
          %Hand{ cards: [ 2,  3,  4,  3,  2], bid: 222, type: :pair2, type_i: 2 },
          %Hand{ cards: [14,  2,  3, 14,  4], bid: 111, type: :pair1, type_i: 1 },
          %Hand{ cards: [ 2,  3,  4,  5,  6], bid:   0, type: :highc, type_i: 0 },
        ],
        input: """
        32T3K 765
        T55J5 684
        KK677 28
        KTJJT 220
        QQQJA 483
        """,
        exp_hands: [
          %Hand{ cards: [ 3,  2, 10,  3, 13], bid: 765, type: :pair1, type_i: 1 },
          %Hand{ cards: [10,  5,  5, 11,  5], bid: 684, type: :kind3, type_i: 3 },
          %Hand{ cards: [13, 13,  6,  7,  7], bid:  28, type: :pair2, type_i: 2 },
          %Hand{ cards: [13, 10, 11, 11, 10], bid: 220, type: :pair2, type_i: 2 },
          %Hand{ cards: [12, 12, 12, 11, 14], bid: 483, type: :kind3, type_i: 3 },
        ],
      ]
    end

    test "parser gets expected sample hands", fixture do
      act_sample_hands = fixture.samples
                         |> parse_input_string()
                         |> Enum.to_list()
      assert act_sample_hands == fixture.exp_sample_hands
    end

    test "parser gets expected hands", fixture do
      act_hands = fixture.input
                  |> parse_input_string()
                  |> Enum.to_list()
      assert act_hands == fixture.exp_hands
    end
  end
end
