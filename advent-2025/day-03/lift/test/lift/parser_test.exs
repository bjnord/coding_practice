defmodule Lift.ParserTest do
  use ExUnit.Case
  doctest Lift.Parser, import: true

  import Lift.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        987654321111111
        811111111111119
        234234234234278
        818181911112111
        """,
        exp_banks: [
          ~c"987654321111111",
          ~c"811111111111119",
          ~c"234234234234278",
          ~c"818181911112111"
        ],
      ]
    end

    test "parser gets expected battery banks", fixture do
      act_banks = fixture.input
                  |> parse_input_string()
                  |> Enum.to_list()
      assert act_banks == fixture.exp_banks
    end
  end
end
