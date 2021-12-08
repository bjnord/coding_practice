defmodule Lanternfish.ParserTest do
  use ExUnit.Case
  doctest Lanternfish.Parser

  describe "puzzle example" do
    setup do
      [
        input: "3,4,3,1,2\n",
        exp_fish: [3, 4, 3, 1, 2],
      ]
    end

    test "parser gets expected fish", fixture do
      act_fish = fixture.input
                 |> Lanternfish.Parser.parse_input_string()
                 |> Enum.map(fn f -> f end)
      assert act_fish == fixture.exp_fish
    end
  end
end
