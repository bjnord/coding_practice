defmodule Camel.HandTest do
  use ExUnit.Case
  doctest Camel.Hand, import: true

  import Camel.Parser
  alias Camel.Hand

  describe "puzzle example" do
    setup do
      [
        hands: [
          %Hand{ cards: [ 3,  2, 10,  3, 13], bid: 765, type: :pair1, type_i: 1 },
          %Hand{ cards: [10,  5,  5, 11,  5], bid: 684, type: :kind3, type_i: 3 },
          %Hand{ cards: [13, 13,  6,  7,  7], bid:  28, type: :pair2, type_i: 2 },
          %Hand{ cards: [13, 10, 11, 11, 10], bid: 220, type: :pair2, type_i: 2 },
          %Hand{ cards: [12, 12, 12, 11, 14], bid: 483, type: :kind3, type_i: 3 },
        ],
        exp_ranks: [
          1,
          4,
          3,
          2,
          5,
        ],
        exp_winnings: 6440,
        strengthened_hands: [
          %Hand{ cards: [ 3,  2, 10,  3, 13], bid: 765, type: :pair1, type_i: 1 },
          %Hand{ cards: [10,  5,  5,  1,  5], bid: 684, type: :kind4, type_i: 5 },
          %Hand{ cards: [13, 13,  6,  7,  7], bid:  28, type: :pair2, type_i: 2 },
          %Hand{ cards: [13, 10,  1,  1, 10], bid: 220, type: :kind4, type_i: 5 },
          %Hand{ cards: [12, 12, 12,  1, 14], bid: 483, type: :kind4, type_i: 5 },
        ],
        exp_part2_ranks: [
          1,
          3,
          2,
          5,
          4,
        ],
        exp_part2_winnings: 5905,
      ]
    end

    test "find hand ranks (part 1)", fixture do
      act_ranks = fixture.hands
                  |> Hand.ranks()
      assert act_ranks == fixture.exp_ranks
    end

    test "find winnings (part 1)", fixture do
      ranks = fixture.hands
              |> Hand.ranks()
      act_winnings = fixture.hands
                     |> Hand.winnings(ranks)
      assert act_winnings == fixture.exp_winnings
    end

    test "strengthen hands with jokers (part 2)", fixture do
      act_s_hands = fixture.hands
                    |> Enum.map(&Hand.strengthen/1)
      assert act_s_hands == fixture.strengthened_hands
    end

    test "find hand ranks (part 2)", fixture do
      act_ranks = fixture.strengthened_hands
                  |> Hand.ranks()
      assert act_ranks == fixture.exp_part2_ranks
    end

    test "find winnings (part 2)", fixture do
      ranks = fixture.strengthened_hands
              |> Hand.ranks()
      act_winnings = fixture.strengthened_hands
                     |> Hand.winnings(ranks)
      assert act_winnings == fixture.exp_part2_winnings
    end
  end

  describe "hand comparison" do
    setup do
      [
        hand_pairs: [
          ["AAAAA", "AA8AA"],
          ["KK7KK", "K6KKK"],
          ["AA8AA", "23332"],
          ["7JJJ7", "7J7JJ"],
          ["23332", "TTT98"],
          ["99943", "89997"],
          ["TTT98", "23432"],
          ["KKAA2", "KKA5A"],
          ["23432", "A23A4"],
          ["Q23Q4", "56Q7Q"],
          ["A23A4", "23456"],
          ["34567", "23456"],
        ],
        exp_maxes: [
          "AAAAA",
          "KK7KK",
          "AA8AA",
          "7JJJ7",
          "23332",
          "99943",
          "TTT98",
          "KKAA2",
          "23432",
          "Q23Q4",
          "A23A4",
          "34567",
        ],
        # TODO add comparisons for part 2
      ]
    end

    test "compare hands (part 1)", fixture do
      act_forward_maxes =
        fixture.hand_pairs
        |> Enum.map(fn [a_str, b_str] ->
          a = parse_hand({a_str, "0"})
          b = parse_hand({b_str, "0"})
          Hand.max(a, b)
        end)
      act_backward_maxes =
        fixture.hand_pairs
        |> Enum.map(fn [a_str, b_str] ->
          a = parse_hand({a_str, "0"})
          b = parse_hand({b_str, "0"})
          Hand.max(b, a)
        end)
      exp_maxes =
        fixture.exp_maxes
        |> Enum.map(fn h_str -> parse_hand({h_str, "0"}) end)
      assert act_forward_maxes == exp_maxes
      assert act_backward_maxes == exp_maxes
    end
  end

  # TODO add tests for hand strengthening / reclassification
end
