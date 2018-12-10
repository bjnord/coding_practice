defmodule StarsTest do
  use ExUnit.Case
  doctest Stars
  doctest InputParser

  import Stars

  test "moves stars" do
    stars = [
      {9, 1, 0, 2},
      {7, 0, -3, 0},
      {3, -2, -1, 1},
    ]
    assert move_stars(stars) == [
      {9, 3, 0, 2},
      {4, 0, -3, 0},
      {2, -1, -1, 1},
    ]
  end

  test "detects visibility" do
    stars = [
      {9, 1, 0, 2},
      {7, 0, -3, 0},
      {3, -2, -1, 1},
    ]
    assert stars_visible?(stars, {-1, -1, 1, 1}) == false
    assert stars_visible?(stars, {-1, -2, 3, 1}) == false
    assert stars_visible?(stars, {3, -2, 7, 0}) == false
    assert stars_visible?(stars, {3, -2, 9, 1}) == true
  end

  test "renders to grid (small example)" do
    stars = [
      {0, -1, 0, 0},
      {-1, 0, 0, 0},
      {1, 0, 0, 0},
      {0, 1, 0, 0},
    ]
    assert render_to_grid(stars, {-1, -2, 2, 1}) == [
      '....',  # -2
      '.#..',  # -1
      '#.#.',  #  0
      '.#..',  #  1
    ]
  end

  test "renders to grid (puzzle example)" do
    stars = [
      {9, 1, 0, 2},
      {7, 0, -1, 0},
      {3, -2, -1, 1},
      {6, 10, -2, -1},
      {2, -4, 2, 2},
      {-6, 10, 2, -2},
      {1, 8, 1, -1},
      {1, 7, 1, 0},
      {-3, 11, 1, -2},
      {7, 6, -1, -1},
      {-2, 3, 1, 0},
      {-4, 3, 2, 0},
      {10, -3, -1, 1},
      {5, 11, 1, -2},
      {4, 7, 0, -1},
      {8, -2, 0, 1},
      {15, 0, -2, 0},
      {1, 6, 1, 0},
      {8, 9, 0, -1},
      {3, 3, -1, 1},
      {0, 5, 0, -1},
      {-2, 2, 2, 0},
      {5, -2, 1, 2},
      {1, 4, 2, 1},
      {-2, 7, 2, -2},
      {3, 6, -1, -1},
      {5, 0, 1, 0},
      {-6, 0, 2, 0},
      {5, 9, 1, -2},
      {14, 7, -2, 0},
      {-3, 6, 2, -1}
    ]
    assert render_to_grid(stars, {-6, -4, 15, 11}) == [
      '........#.............',
      '................#.....',
      '.........#.#..#.......',
      '......................',
      '#..........#.#.......#',
      '...............#......',
      '....#.................',
      '..#.#....#............',
      '.......#..............',
      '......#...............',
      '...#...#.#...#........',
      '....#..#..#.........#.',
      '.......#..............',
      '...........#..#.......',
      '#...........#.........',
      '...#.......#..........',
    ]
  end
end
