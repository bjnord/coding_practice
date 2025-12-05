defmodule CafeTest do
  use ExUnit.Case
  doctest Cafe

  describe "puzzle example" do
    setup do
      [
        inventory: {
          [
            {3, 5},
            {10, 14},
            {16, 20},
            {12, 18},
          ],
          [
            1,
            5,
            8,
            11,
            17,
            32,
          ]
        },
        exp_fresh_ingredients: [
          5,
          11,
          17,
        ],
      ]
    end

    test "find fresh ingredients", fixture do
      act_fresh_ingredients = fixture.inventory
                              |> Cafe.find_fresh_ingredients()
      assert act_fresh_ingredients == fixture.exp_fresh_ingredients
    end
  end
end
