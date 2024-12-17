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
        exp_computer: {
          {729, 0, 0},
          %{0 => 0, 1 => 1, 2 => 5, 3 => 4, 4 => 3, 5 => 0},
        },
      ]
    end

    test "parser gets expected computer (registers and program)", fixture do
      act_computer = fixture.input
                     |> parse_input_string()
      assert act_computer == fixture.exp_computer
    end
  end
end
