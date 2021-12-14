defmodule Polymer.ParserTest do
  use ExUnit.Case
  doctest Polymer.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        NNCB

        CH -> B
        HH -> N
        CB -> H
        NH -> C
        HB -> C
        HC -> B
        HN -> C
        NN -> C
        BH -> H
        NC -> B
        NB -> B
        BN -> B
        BB -> N
        BC -> B
        CC -> N
        CN -> C
        """,
        exp_template: "NNCB",
        exp_rules: %{
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
      ]
    end

    test "parser gets expected template and rules", fixture do
      {act_template, act_rules} =
        fixture.input
        |> Polymer.Parser.parse_input_string()
      assert act_template == fixture.exp_template
      assert act_rules == fixture.exp_rules
    end
  end
end
