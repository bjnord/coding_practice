defmodule ChronalTest do
  use ExUnit.Case
  doctest Chronal

  import Chronal

  test "computes Manhattan distance" do
    assert manhattan({2, 3}, {5, 6}) == 6
    # "Distance of {1, 6}, {3, 5}, {2, 3} from {-1, 5} are 3, 4, 5 respectively."
    assert manhattan({-1, 5}, {1, 6}) == 3
    assert manhattan({-1, 5}, {3, 5}) == 4
    assert manhattan({-1, 5}, {2, 3}) == 5
  end
end
