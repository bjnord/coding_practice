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
        exp_alignment_c: [
          {5, 168},
          {2, 206},
        ],
        exp_cheapest_fuel_c: 168,
      ]
    end

    test "alignment fuel cost calculator (simple)", fixture do
      act_alignment = fixture.exp_alignment
                      |> Enum.map(fn a -> elem(a, 0) end)
                      |> Enum.map(fn p -> Whale.align_crabs_fuel(p, fixture.positions) end)
      assert act_alignment == fixture.exp_alignment |> Enum.map(fn a -> elem(a, 1) end)
    end

    test "cheapest fuel cost finder (simple)", fixture do
      assert Whale.find_cheapest_fuel(fixture.positions) == fixture.exp_cheapest_fuel
    end

    test "alignment fuel cost calculator (complex)", fixture do
      act_alignment_c = fixture.exp_alignment_c
                        |> Enum.map(fn a -> elem(a, 0) end)
                        |> Enum.map(fn p -> Whale.align_crabs_fuel_c(p, fixture.positions) end)
      assert act_alignment_c == fixture.exp_alignment_c |> Enum.map(fn a -> elem(a, 1) end)
    end

    test "cheapest fuel cost finder (complex)", fixture do
      assert Whale.find_cheapest_fuel_c(fixture.positions) == fixture.exp_cheapest_fuel_c
    end
  end
end
