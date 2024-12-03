defmodule Program.ParserTest do
  use ExUnit.Case
  doctest Program.Parser, import: true

  import Program.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
        """,
        exp_instructions: [
          {:mul, [2, 4]},
          {:mul, [5, 5]},
          {:mul, [11, 8]},
          {:mul, [8, 5]},
        ],
      ]
    end

    test "parser gets expected instructions", fixture do
      act_instructions = fixture.input
                         |> parse_input_string()
      assert act_instructions == fixture.exp_instructions
    end
  end
end
