defmodule ChronalTest do
  use ExUnit.Case
  doctest Chronal

  import Chronal

  test "parses input point" do
    assert input_point("3, 4\n") == {3, 4}
  end

  test "computes Manhattan distance" do
    assert manhattan({2, 3}, {5, 6}) == 6
    # "Distance of {1, 6}, {3, 5}, {2, 3} from {-1, 5} are 3, 4, 5 respectively."
    assert manhattan({-1, 5}, {1, 6}) == 3
    assert manhattan({-1, 5}, {3, 5}) == 4
    assert manhattan({-1, 5}, {2, 3}) == 5
  end

  # something fun I thought of when watching José Valim's Twitch stream
  # for day 6: why not test exactly what's listed in the puzzle notes?
  test "builds and renders grid" do
    points = [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]
    bounds = {0, 0, 9, 9}
    grid = grid(points, bounds)
    assert render_grid(grid, points, bounds) == [
      'aaaaa.cccc',
      'aAaaa.cccc',
      'aaaddecccc',
      'aadddeccCc',
      '..dDdeeccc',
      'bb.deEeecc',
      'bBb.eeee..',
      'bbb.eeefff',
      'bbb.eeffff',
      'bbb.ffffFf',
    ]
  end

  test "finds closest points" do
    points = [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]
    assert closest_points({4, 1}, points) == [{1, 1}]
    assert closest_points({4, 2}, points) == [{3, 4}]
    assert closest_points({5, 2}, points) == [{5, 5}]
    assert closest_points({1, 6}, points) == [{1, 6}]
    assert closest_points({3, 6}, points) == [{1, 6}, {3, 4}]
    assert closest_points({8, 5}, points) == [{8, 3}]
    assert closest_points({8, 6}, points) == [{8, 3}, {8, 9}]
    assert closest_points({8, 7}, points) == [{8, 9}]
  end

  test "finds total distance to all points" do
    points = [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]
    assert total_distance({4, 3}, points) == 30
  end

  test "finds point area" do
    points = [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]
    grid = grid(points, bounds(points))
    assert point_area({3, 4}, grid) == 9
    assert point_area({5, 5}, grid) == 17
  end

  test "finds points with finite areas" do
    points = [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]
    bounds = bounds(points)
    grid = grid(points, bounds)
    assert finite_area_points(points, grid, bounds) == [{3, 4}, {5, 5}]
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
