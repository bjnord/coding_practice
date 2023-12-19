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
      ]
    end

    test "find part decisions and accepted rating", fixture do
      act_decisions =
        fixture.parts
        |> Enum.map(fn part -> Rules.flow(fixture.workflows, part) end)
      assert act_decisions == fixture.exp_decisions
      act_accepted_rating =
        Rules.accepted_rating(fixture.workflows, fixture.parts)
      assert act_accepted_rating == fixture.exp_accepted_rating
    end
  end
end
