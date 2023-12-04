defmodule Scratch.ParserTest do
  use ExUnit.Case
  doctest Scratch.Parser, import: true

  import Scratch.Parser
  alias Scratch.Card

  describe "puzzle example" do
    setup do
      [
        input: """
        Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
        """,
        exp_cards: [
          %Card{
            number: 1,
            winning: [ 41, 48, 83, 86, 17 ],
            have: [ 83, 86, 6, 31, 17, 9, 48, 53 ],
          },
          %Card{
            number: 2,
            winning: [ 13, 32, 20, 16, 61 ],
            have: [ 61, 30, 68, 82, 17, 32, 24, 19 ],
          },
          %Card{
            number: 3,
            winning: [ 1, 21, 53, 59, 44 ],
            have: [ 69, 82, 63, 72, 16, 21, 14, 1 ],
          },
          %Card{
            number: 4,
            winning: [ 41, 92, 73, 84, 69 ],
            have: [ 59, 84, 76, 51, 58, 5, 54, 83 ],
          },
          %Card{
            number: 5,
            winning: [ 87, 83, 26, 28, 32 ],
            have: [ 88, 30, 70, 12, 93, 22, 82, 36 ],
          },
          %Card{
            number: 6,
            winning: [ 31, 18, 13, 56, 72 ],
            have: [ 74, 77, 10, 23, 35, 67, 36, 11 ],
          },
        ],
      ]
    end

    test "parser gets expected cards", fixture do
      act_cards = fixture.input
                  |> parse_input_string()
                  |> Enum.to_list()
      assert act_cards == fixture.exp_cards
    end
  end
end
