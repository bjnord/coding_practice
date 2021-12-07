defmodule WhaleTest do
  use ExUnit.Case
  doctest Whale

  describe "puzzle example" do
    setup do
      [
        positions: [16, 1, 2, 0, 4, 2, 7, 1, 2, 14],
        exp_alignment: [
          {2, 37},
          {1, 41},
          {3, 39},
          {10, 71},
        ],
        exp_cheapest_fuel: 37,
      ]
    end

    test "alignment fuel cost calculator", fixture do
      act_alignment = fixture.exp_alignment
                      |> Enum.map(fn a -> elem(a, 0) end)
                      |> Enum.map(fn p -> Whale.align_crabs_fuel(p, fixture.positions) end)
      assert act_alignment == fixture.exp_alignment |> Enum.map(fn a -> elem(a, 1) end)
    end

    test "cheapest fuel cost finder", fixture do
      assert Whale.find_cheapest_fuel(fixture.positions) == fixture.exp_cheapest_fuel
    end
  end
end
