defmodule MineCart.InputParserTest do
  use ExUnit.Case
  doctest MineCart.InputParser

  test "trims only trailing spaces" do
    {grid, _carts} = MineCart.InputParser.parse_line("   \\--/   \n", 5, %{}, [])
    assert grid == %{
      {5, 3} => :curve_nw,
      {5, 4} => :horiz,
      {5, 5} => :horiz,
      {5, 6} => :curve_ne,
    }
  end
end
