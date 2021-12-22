defmodule Reactor.ParserTest do
  use ExUnit.Case
  doctest Reactor.Parser

  alias Reactor.Parser, as: Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        on x=10..12,y=10..12,z=10..12
        on x=11..13,y=11..13,z=11..13
        off x=9..11,y=9..11,z=9..11
        on x=10..10,y=10..10,z=10..10
        """,
        exp_steps: [
          {:on, {{10, 10, 10}, {12, 12, 12}}},
          {:on, {{11, 11, 11}, {13, 13, 13}}},
          {:off, {{9, 9, 9}, {11, 11, 11}}},
          {:on, {{10, 10, 10}, {10, 10, 10}}},
        ],
        mixed_input: """
        on x=3..43,y=23..47,z=11..41
        off x=-7..19,y=-11..29,z=-37..-31
        """,
        exp_mixed_steps: [
          {:on, {{3, 23, 11}, {43, 47, 41}}},
          {:off, {{-7, -11, -37}, {19, 29, -31}}},
        ],
      ]
    end

    test "parser gets expected steps (smaller example)", fixture do
      assert Parser.parse(fixture.input) == fixture.exp_steps
    end

    test "parser gets expected steps (mixed example)", fixture do
      assert Parser.parse(fixture.mixed_input) == fixture.exp_mixed_steps
    end
  end
end
