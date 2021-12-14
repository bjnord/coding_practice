defmodule Polymer.StepperTest do
  use ExUnit.Case
  doctest Polymer.Stepper

  describe "puzzle example" do
    setup do
      [
        template: "NNCB",
        rule_lines: """
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
        steps_4: """
        NCNBCHB
        NBCCNBBBCBHCB
        NBBBCNCCNBBNBNBBCHBHHBCHB
        NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB
        """,
        exp_counts_4: [
          %{?N => 2, ?C => 1, ?B => 1},
          %{?N => 2, ?C => 2, ?B => 2, ?H => 1},
          %{?N => 2, ?B => 6, ?C => 4, ?H => 1},
          %{?N => 5, ?B => 11, ?C => 5, ?H => 4},
          %{?N => 11, ?B => 23, ?C => 10, ?H => 5},
        ],
        exp_min_max_4: {5, 23},
        exp_min_max_10: {161, 1749},
      ]
    end

    test "counter gets expected counts (template and 4 steps)", fixture do
      [fixture.template | String.split(fixture.steps_4, "\n", trim: true)]
      |> Enum.zip(fixture.exp_counts_4)
      |> Enum.each(fn {polymer, exp_counts} ->
        stepper = Polymer.Stepper.new("#{polymer}\n\n#{fixture.rule_lines}")
        assert Polymer.Stepper.element_count(stepper) == exp_counts
      end)
    end

    test "min/max function gets expected values (4th step)", fixture do
      polymer4 =
        String.split(fixture.steps_4, "\n", trim: true)
        |> List.last()
      act_min_max =
        Polymer.Stepper.new("#{polymer4}\n\n#{fixture.rule_lines}")
        |> Polymer.Stepper.min_max()
      assert act_min_max == fixture.exp_min_max_4
    end
  end
end
