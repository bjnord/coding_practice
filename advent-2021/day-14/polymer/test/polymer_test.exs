defmodule PolymerTest do
  use ExUnit.Case
  doctest Polymer

  describe "puzzle example" do
    setup do
      [
        template: "NNCB",
        rules: %{
          {?C, ?H} => ?B,
          {?H, ?H} => ?N,
          {?C, ?B} => ?H,
          {?N, ?H} => ?C,
          {?H, ?B} => ?C,
          {?H, ?C} => ?B,
          {?H, ?N} => ?C,
          {?N, ?N} => ?C,
          {?B, ?H} => ?H,
          {?N, ?C} => ?B,
          {?N, ?B} => ?B,
          {?B, ?N} => ?B,
          {?B, ?B} => ?N,
          {?B, ?C} => ?B,
          {?C, ?C} => ?N,
          {?C, ?N} => ?C,
        },
        exp_steps_4: """
        NCNBCHB
        NBCCNBBBCBHCB
        NBBBCNCCNBBNBNBBCHBHHBCHB
        NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB
        """,
        exp_min_10: 161,
        exp_max_10: 1749,
      ]
    end

    test "stepper gets expected polymers", fixture do
      {_polymer, act_steps} =
        1..4
        |> Enum.reduce({fixture.template, []}, fn (_n, {polymer, steps}) ->
          new_polymer = Polymer.step(polymer, fixture.rules)
          {new_polymer, [new_polymer | steps]}
        end)
      assert Enum.reverse(act_steps) == String.split(fixture.exp_steps_4, "\n", trim: true)
    end

    test "counter gets expected min/max occurrences (10 iterations)", fixture do
      {act_min, act_max} =
        1..10
        |> Enum.reduce(fixture.template, fn (_n, polymer) ->
          Polymer.step(polymer, fixture.rules)
        end)
        |> Polymer.min_max()
      assert act_min == fixture.exp_min_10
      assert act_max == fixture.exp_max_10
    end
  end
end
