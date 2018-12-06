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

  test "computes bounding box (minimal rectangle)" do
    points = [{1, 2}, {5, 2}, {5, 7}, {1, 7}]
    assert bounds(points) == {1, 2, 5, 7}
  end

  test "computes bounding box (all unique rows/cols)" do
    points = [{1, 4}, {8, 3}, {2, 7}, {5, 6}]
    assert bounds(points) == {1, 3, 8, 7}
  end

  test "computes bounding box (day 6 example)" do
    points = [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]
    assert bounds(points) == {1, 1, 8, 9}
  end
end
