defmodule Whale.ParserTest do
  use ExUnit.Case
  doctest Whale.Parser

  describe "puzzle example" do
    setup do
      [
        input: "16,1,2,0,4,2,7,1,2,14\n",
        exp_positions: [16, 1, 2, 0, 4, 2, 7, 1, 2, 14],
      ]
    end

    test "parser gets expected crab positions", fixture do
      act_positions = fixture.input
                 |> Whale.Parser.parse_input_string(fixture.input)
                 |> Enum.map(fn p -> p end)
      assert act_positions == fixture.exp_positions
    end
  end
end
