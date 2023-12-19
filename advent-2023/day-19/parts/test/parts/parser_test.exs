defmodule Parts.ParserTest do
  use ExUnit.Case
  doctest Parts.Parser, import: true

  import Parts.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        px{a<2006:qkq,m>2090:A,rfg}
        pv{a>1716:R,A}
        lnx{m>1548:A,A}
        rfg{s<537:gd,x>2440:R,A}
        qs{s>3448:A,lnx}
        qkq{x<1416:A,crn}
        crn{x>2662:A,R}
        in{s<1351:px,qqz}
        qqz{s>2770:qs,m<1801:hdj,R}
        gd{a>3333:R,R}
        hdj{m>838:A,pv}

        {x=787,m=2655,a=1222,s=2876}
        {x=1679,m=44,a=2067,s=496}
        {x=2036,m=264,a=79,s=2244}
        {x=2461,m=1339,a=466,s=291}
        {x=2127,m=1623,a=2188,s=1013}
        """,
        exp_parts: [
          %{ x:  787, m: 2655, a: 1222, s: 2876 },
          %{ x: 1679, m:   44, a: 2067, s:  496 },
          %{ x: 2036, m:  264, a:   79, s: 2244 },
          %{ x: 2461, m: 1339, a:  466, s:  291 },
          %{ x: 2127, m: 1623, a: 2188, s: 1013 },
        ],
        exp_workflows: %{
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
      ]
    end

    test "parser gets expected workflows and parts", fixture do
      {act_workflows, act_parts} =
        fixture.input
        |> parse_input_string()
      assert act_workflows == fixture.exp_workflows
      assert act_parts == fixture.exp_parts
    end
  end
end
