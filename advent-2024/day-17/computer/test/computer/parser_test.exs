defmodule Computer.ParserTest do
  use ExUnit.Case
  doctest Computer.Parser, import: true

  import Computer.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        Register A: 729
        Register B: 0
        Register C: 0

        Program: 0,1,5,4,3,0
        """,
        exp_reg_program: {
          {729, 0, 0},
          [0, 1, 5, 4, 3, 0],
        },
      ]
    end

    test "parser gets expected registers and program", fixture do
      act_reg_program = fixture.input
                        |> parse_input_string()
      assert act_reg_program == fixture.exp_reg_program
    end
  end
end
