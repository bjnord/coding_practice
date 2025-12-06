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
        exp_combined_ranges: [
          {3, 5},
          {10, 20},
        ],
        exp_ingredient_count: 14,
      ]
    end

    test "find fresh ingredients", fixture do
      act_fresh_ingredients =
        fixture.inventory
        |> Cafe.find_fresh_ingredients()
      assert act_fresh_ingredients == fixture.exp_fresh_ingredients
    end

    test "combine ranges", fixture do
      act_combined_ranges =
        fixture.inventory
        |> Cafe.combine_ranges()
        |> Enum.reverse()
      assert act_combined_ranges == fixture.exp_combined_ranges
    end

    test "count ingredients in ranges", fixture do
      act_ingredient_count =
        fixture.inventory
        |> Cafe.combine_ranges()
        |> Cafe.count_ingredients()
      assert act_ingredient_count == fixture.exp_ingredient_count
    end
  end
end
