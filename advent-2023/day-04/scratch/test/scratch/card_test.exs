defmodule Scratch.CardTest do
  use ExUnit.Case
  doctest Scratch.Card, import: true

  alias Scratch.Card, as: Card

  describe "puzzle example" do
    setup do
      [
        cards: [
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
        exp_points: [
          8,
          2,
          2,
          1,
          0,
          0,
        ],
        exp_copies: %{
          1 => 1,
          2 => 2,
          3 => 4,
          4 => 8,
          5 => 14,
          6 => 1,
        },
      ]
    end

    test "find card point values", fixture do
      act_points = fixture.cards
                   |> Enum.map(&Card.value/1)
      assert act_points == fixture.exp_points
    end

    test "find card copy counts", fixture do
      act_copies = fixture.cards
                   |> Card.copies()
      assert act_copies == fixture.exp_copies
    end
  end
end
