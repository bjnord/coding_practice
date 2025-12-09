defmodule Tile.ParserTest do
  use ExUnit.Case
  doctest Tile.Parser, import: true

  import Tile.Parser
  alias Decor.Grid

  describe "puzzle example" do
    setup do
      [
        input: """
        7,1
        11,1
        11,7
        9,7
        9,5
        2,5
        2,3
        7,3
        """,
        exp_grid: %Grid{
          size: %{y: 8, x: 12},
          squares: %{
            {1, 7} => ?#, {1, 11} => ?#,
            {3, 2} => ?#, {3, 7} => ?#,
            {5, 2} => ?#, {5, 9} => ?#,
            {7, 9} => ?#, {7, 11} => ?#,
          },
        },
      ]
    end

    test "produces correct grid", fixture do
      act_grid = fixture.input
                 |> parse_input_string()
      assert act_grid == fixture.exp_grid
    end
  end
end
