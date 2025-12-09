defmodule TileTest do
  use ExUnit.Case
  doctest Tile

  import Tile
  alias Decor.Grid

  describe "puzzle example" do
    setup do
      [
        grid: %Grid{
          size: %{y: 8, x: 12},
          squares: %{
            {1, 7} => ?#, {1, 11} => ?#,
            {3, 2} => ?#, {3, 7} => ?#,
            {5, 2} => ?#, {5, 9} => ?#,
            {7, 9} => ?#, {7, 11} => ?#,
          },
        },
        exp_area: 50,
      ]
    end

    test "finds largest area", fixture do
      act_area = fixture.grid
                 |> max_area_tiles()
                 |> then(fn {a, b} -> tile_area(a, b) end)
      assert act_area == fixture.exp_area
    end
  end
end
