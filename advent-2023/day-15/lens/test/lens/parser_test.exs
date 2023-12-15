defmodule Lens.ParserTest do
  use ExUnit.Case
  doctest Lens.Parser, import: true

  import Lens.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
        """,
        exp_iv: [
          {0, :install, "rn", 1},
          {0, :remove,  "cm"},
          {1, :install, "qp", 3},
          {0, :install, "cm", 2},
          {1, :remove,  "qp"},
          {3, :install, "pc", 4},
          {3, :install, "ot", 9},
          {3, :install, "ab", 5},
          {3, :remove,  "pc"},
          {3, :install, "pc", 6},
          {3, :install, "ot", 7},
        ],
      ]
    end

    test "parser gets expected IV", fixture do
      act_iv = fixture.input
               |> parse_input_string(part: 2)
      assert act_iv == fixture.exp_iv
    end
  end
end
