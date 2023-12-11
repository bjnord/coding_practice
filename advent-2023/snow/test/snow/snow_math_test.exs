defmodule Snow.SnowMathTest do
  use ExUnit.Case
  doctest Snow.SnowMath

  alias Snow.SnowMath

  test "Least Common Multiple (LCM)" do
    numbers = [2, 3, 4, 6, 7, 9]
    exp = 2 * 2 * 3 * 3 * 7
    assert SnowMath.lcm(numbers) == exp
  end

  # no AoC year is complete without...:
  test "Manhattan distance (3D)" do
    pos1 = {1105, -1205, 1229}
    pos2 = {-92, -2380, -20}
    assert SnowMath.manhattan(pos1, pos2) == 3621
  end
  test "Manhattan distance (2D)" do
    pos1 = {1105, -1205}
    pos2 = {-92, -2380}
    assert SnowMath.manhattan(pos1, pos2) == 2372
  end
end
