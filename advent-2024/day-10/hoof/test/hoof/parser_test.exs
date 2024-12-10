defmodule Hoof.ParserTest do
  use ExUnit.Case
  doctest Hoof.Parser, import: true

  alias History.Grid
  import Hoof.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        0123
        1234
        8765
        9876
        """,
        exp_grid: %Grid{
          size: %{y: 4, x: 4},
          squares: %{
            {0, 0} => 0, {0, 1} => 1, {0, 2} => 2, {0, 3} => 3,
            {1, 0} => 1, {1, 1} => 2, {1, 2} => 3, {1, 3} => 4,
            {2, 0} => 8, {2, 1} => 7, {2, 2} => 6, {2, 3} => 5,
            {3, 0} => 9, {3, 1} => 8, {3, 2} => 7, {3, 3} => 6,
          },
        },
      ]
    end

    test "parser produces expected grid", fixture do
      act_grid = fixture.input
                 |> parse_input_string()
      assert act_grid == fixture.exp_grid
    end
  end
end
