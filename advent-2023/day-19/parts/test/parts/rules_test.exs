defmodule Parts.RulesTest do
  use ExUnit.Case
  doctest Parts.Rules, import: true

  alias Parts.Rules

  describe "puzzle example" do
    setup do
      [
        parts: [
          %{ x:  787, m: 2655, a: 1222, s: 2876 },
          %{ x: 1679, m:   44, a: 2067, s:  496 },
          %{ x: 2036, m:  264, a:   79, s: 2244 },
          %{ x: 2461, m: 1339, a:  466, s:  291 },
          %{ x: 2127, m: 1623, a: 2188, s: 1013 },
        ],
        workflows: %{
          :px  => [
            { :a, ?<, 2006,    :qkq },
            { :m, ?>, 2090, :accept },
            :rfg,
          ],
          :pv  => [
            { :a, ?>, 1716, :reject },
            :accept,
          ],
          :lnx => [
            { :m, ?>, 1548, :accept },
            :accept,
          ],
          :rfg => [
            { :s, ?<,  537,     :gd },
            { :x, ?>, 2440, :reject },
            :accept,
          ],
          :qs  => [
            { :s, ?>, 3448, :accept },
            :lnx,
          ],
          :qkq => [
            { :x, ?<, 1416, :accept },
            :crn,
          ],
          :crn => [
            { :x, ?>, 2662, :accept },
            :reject,
          ],
          :in  => [
            { :s, ?<, 1351,     :px },
            :qqz,
          ],
          :qqz => [
            { :s, ?>, 2770,     :qs },
            { :m, ?<, 1801,    :hdj },
            :reject,
          ],
          :gd  => [
            { :a, ?>, 3333, :reject },
            :reject,
          ],
          :hdj => [
            { :m, ?>,  838, :accept },
            :pv,
          ],
        },
        exp_decisions: [
          :accept,
          :reject,
          :accept,
          :reject,
          :accept
        ],
        exp_accepted_rating: 19114,
        exp_rule_ranges_px: [
          {
            %{x: {1,4000}, m: {1,4000}, a: {1,2005}, s: {1,4000}},
            :qkq,
          },
          {
            %{x: {1,4000}, m: {2091,4000}, a: {2006,4000}, s: {1,4000}},
            :accept,
          },
          {
            %{x: {1,4000}, m: {1,2090}, a: {2006,4000}, s: {1,4000}},
            :rfg,
          },
        ],
        exp_rule_ranges_rfg: [
          {
            %{x: {1,4000}, m: {1,4000}, a: {1,4000}, s: {1,536}},
            :gd,
          },
          {
            %{x: {2441,4000}, m: {1,4000}, a: {1,4000}, s: {537,4000}},
            :reject,
          },
          {
            %{x: {1,2440}, m: {1,4000}, a: {1,4000}, s: {537,4000}},
            :accept,
          },
        ],
        exp_rule_ranges_in: [
          {
            %{x: {1,4000}, m: {1,4000}, a: {1,4000}, s: {1,1350}},
            :px,
          },
          {
            %{x: {1,4000}, m: {1,4000}, a: {1,4000}, s: {1351,4000}},
            :qqz,
          },
        ],
        exp_rule_ranges_gd: [
          {
            %{x: {1,4000}, m: {1,4000}, a: {3334,4000}, s: {1,4000}},
            :reject,
          },
          {
            %{x: {1,4000}, m: {1,4000}, a: {1,3333}, s: {1,4000}},
            :reject,
          },
        ],
        exp_intersections: [
          {
            %{x: {1,4000}, m: {1,4000}, a: {1,4000}, s: {1,4000}},
            %{x: {1,2221}, m: {1,4000}, a: {3334,4000}, s: {1,4000}},
            %{x: {1,2221}, m: {1,4000}, a: {3334,4000}, s: {1,4000}},
          },
          {
            %{x: {1,4000}, m: {1011,2022}, a: {1,4000}, s: {1,4000}},
            %{x: {1,4000}, m: {1,4000}, a: {1,4000}, s: {3033,3444}},
            %{x: {1,4000}, m: {1011,2022}, a: {1,4000}, s: {3033,3444}},
          },
          {
            %{x: {1,2227}, m: {1,4000}, a: {3334,4000}, s: {1,4000}},
            %{x: {1,4000}, m: {707,4000}, a: {1,4000}, s: {1,1722}},
            %{x: {1,2227}, m: {707,4000}, a: {3334,4000}, s: {1,1722}},
          },
          {
            %{x: {0,0}, m: {2001,4000}, a: {1,4000}, s: {1,3000}},
            %{x: {1,4000}, m: {1,2000}, a: {0,0}, s: {3001,4000}},
            %{x: {0,0}, m: {0,0}, a: {0,0}, s: {0,0}},
          },
        ],
        exp_distinct_combos: 167409079868000,
      ]
    end

    test "find part decisions and accepted rating", fixture do
      act_decisions =
        fixture.parts
        |> Enum.map(fn part -> Rules.flow(fixture.workflows, part) end)
      assert act_decisions == fixture.exp_decisions
      act_accepted_rating =
        Rules.accepted_rating({fixture.workflows, fixture.parts})
      assert act_accepted_rating == fixture.exp_accepted_rating
    end

    test "find rule ranges", fixture do
      act_rule_ranges_px = fixture.workflows.px
                           |> Rules.rule_ranges()
      assert act_rule_ranges_px == fixture.exp_rule_ranges_px
      act_rule_ranges_rfg = fixture.workflows.rfg
                            |> Rules.rule_ranges()
      assert act_rule_ranges_rfg == fixture.exp_rule_ranges_rfg
      act_rule_ranges_in = fixture.workflows.in
                           |> Rules.rule_ranges()
      assert act_rule_ranges_in == fixture.exp_rule_ranges_in
      act_rule_ranges_gd = fixture.workflows.gd
                           |> Rules.rule_ranges()
      assert act_rule_ranges_gd == fixture.exp_rule_ranges_gd
    end

    test "find intersections", fixture do
      fixture.exp_intersections
      |> Enum.each(fn {a, b, exp_intersection} ->
        act_intersection = Rules.intersection(a, b)
        assert act_intersection == exp_intersection
      end)
    end

    test "find distinct combos", fixture do
      act_distinct_combos = Rules.distinct_combos(fixture.workflows)
      assert act_distinct_combos == fixture.exp_distinct_combos
    end
  end
end
