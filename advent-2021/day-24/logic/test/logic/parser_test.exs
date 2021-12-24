defmodule Logic.ParserTest do
  use ExUnit.Case
  doctest Logic.Parser

  alias Logic.Parser, as: Parser

  describe "puzzle example" do
    setup do
      [
        input1: """
        inp x
        mul x -1
        """,
        input2: """
        inp z
        inp x
        mul z 3
        eql z x
        """,
        input3: """
        inp w
        add z w
        mod z 2
        div w 2
        add y w
        mod y 2
        div w 2
        add x w
        mod x 2
        div w 2
        mod w 2
        """,
        exp_program2: [
          {:inp, :z},
          {:inp, :x},
          {:mul, :z, 3},
          {:eql, :z, :x},
        ],
        exp_program3: [
          {:inp, :w},
          {:add, :z, :w},
          {:mod, :z, 2},
          {:div, :w, 2},
          {:add, :y, :w},
          {:mod, :y, 2},
          {:div, :w, 2},
          {:add, :x, :w},
          {:mod, :x, 2},
          {:div, :w, 2},
          {:mod, :w, 2},
        ],
      ]
    end

    test "parser gets expected program (example 2)", fixture do
      assert Parser.parse(fixture.input2) == fixture.exp_program2
    end

    test "parser gets expected program (example 3)", fixture do
      assert Parser.parse(fixture.input3) == fixture.exp_program3
    end
  end
end
