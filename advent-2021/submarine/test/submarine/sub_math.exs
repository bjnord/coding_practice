defmodule Submarine.SubMathTest do
  use ExUnit.Case
  doctest Submarine.SubMath

  alias Submarine.SubMath, as: SubMath

  # no AoC year is complete without...:
  test "Manhattan distance" do
    pos1 = {1105, -1205, 1229}
    pos2 = {-92, -2380, -20}
    assert SubMath.manhattan(pos1, pos2) == 3621
  end
end
