defmodule ClawTest do
  use ExUnit.Case
  doctest Claw

  describe "puzzle example" do
    setup do
      [
        machines: [
          %{
            a: {34, 94},
            b: {67, 22},
            prize: {5400, 8400},
          },
          %{
            a: {66, 26},
            b: {21, 67},
            prize: {12176, 12748},
          },
          %{
            a: {86, 17},
            b: {37, 84},
            prize: {6450, 7870},
          },
          %{
            a: {23, 69},
            b: {71, 27},
            prize: {10279, 18641},
          },
        ],
        exp_ab_values: [
          {80, 40},
          nil,
          {38, 86},
          nil,
        ],
        exp_costs: [
          280,
          0,
          200,
          0,
        ],
        exp_ab_values_2: [
          nil,
          {118679050709, 103199174542},
          nil,
          {102851800151, 107526881786},
        ],
        exp_costs_2: [
          0,
          459236326669,
          0,
          416082282239,
        ],
      ]
    end

    test "finds A and B values", fixture do
      act_ab_values = fixture.machines
                      |> Enum.map(&Claw.ab_values/1)
      assert act_ab_values == fixture.exp_ab_values
    end

    test "finds costs", fixture do
      act_costs = fixture.machines
                  |> Enum.map(&Claw.cost/1)
      assert act_costs == fixture.exp_costs
    end

    test "finds A and B values (part 2)", fixture do
      act_ab_values = fixture.machines
                      |> Enum.map(&Claw.higher/1)
                      |> Enum.map(&Claw.ab_values/1)
      assert act_ab_values == fixture.exp_ab_values_2
    end

    test "finds costs (part 2)", fixture do
      act_costs = fixture.machines
                  |> Enum.map(&Claw.higher/1)
                  |> Enum.map(&Claw.cost/1)
      assert act_costs == fixture.exp_costs_2
    end
  end
end
