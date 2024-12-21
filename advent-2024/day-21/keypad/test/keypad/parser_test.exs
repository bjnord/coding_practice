defmodule Keypad.ParserTest do
  use ExUnit.Case
  doctest Keypad.Parser, import: true

  import Keypad.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        029A
        980A
        179A
        456A
        379A
        """,
        exp_codes: [
          ~c"029A",
          ~c"980A",
          ~c"179A",
          ~c"456A",
          ~c"379A",
        ],
      ]
    end

    test "parser gets expected codes", fixture do
      act_codes = fixture.input
                  |> parse_input_string()
                  |> Enum.to_list()
      assert act_codes == fixture.exp_codes
    end
  end
end
