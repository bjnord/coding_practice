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
        matchsticks: """
        add x 21
        inp w
        mul z 0
        add z -4
        add z w
        mul w -1
        add x w
        add x z
        inp w
        mul z 0
        add z -4
        add z w
        mul w -1
        add x w
        add x z
        inp w
        mul z 0
        add z -4
        add z w
        mul w -1
        add x w
        add x z
        inp w
        mul z 0
        add z -4
        add z w
        mul w -1
        add x w
        add x z
        inp w
        mul z 0
        add z -4
        add z w
        mul w -1
        add x w
        add x z
        inp w
        mul w -1
        add x w
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
        exp_matchsticks: [
          {:add, :x, 21},
          # 21
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 17
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 13
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 9
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 5
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 1
          {:inp, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
        ],
      ]
    end

    test "parser gets expected program (example 2)", fixture do
      assert Parser.parse(fixture.input2) == fixture.exp_program2
    end

    test "parser gets expected program (example 3)", fixture do
      assert Parser.parse(fixture.input3) == fixture.exp_program3
    end

    test "parser gets expected program (matchsticks)", fixture do
      assert Parser.parse(fixture.matchsticks) == fixture.exp_matchsticks
    end
  end
end
