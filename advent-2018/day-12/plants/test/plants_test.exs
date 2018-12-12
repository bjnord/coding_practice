defmodule PlantsTest do
  use ExUnit.Case
  doctest Plants
  doctest InputParser

  import Plants

  test "computes sucessive generations" do
    # example from the day 12 puzzle web page
    rules = %{
      0 => false,
      1 => false,
      2 => false,
      3 => true,
      4 => true,
      5 => false,
      6 => false,
      7 => false,
      8 => true,
      9 => false,
      10 => true,
      11 => true,
      12 => true,
      13 => false,
      14 => false,
      15 => true,
      16 => false,
      17 => false,
      18 => false,
      19 => false,
      20 => false,
      21 => true,
      22 => false,
      23 => true,
      24 => false,
      25 => false,
      26 => true,
      27 => true,
      28 => true,
      29 => true,
      30 => true,
      31 => false,
    }
    generations = [
      "...#...#....#.....#..#..#..#...........",
      "...##..##...##....#..#..#..##..........",
      "..#.#...#..#.#....#..#..#...#..........",
      "...#.#..#...#.#...#..#..##..##.........",
      "....#...##...#.#..#..#...#...#.........",
      "....##.#.#....#...#..##..##..##........",
      "...#..###.#...##..#...#...#...#........",
      "...#....##.#.#.#..##..##..##..##.......",
      "...##..#..#####....#...#...#...#.......",
      "..#.#..#...#.##....##..##..##..##......",
      "...#...##...#.#...#.#...#...#...#......",
      "...##.#.#....#.#...#.#..##..##..##.....",
      "..#..###.#....#.#...#....#...#...#.....",
      "..#....##.#....#.#..##...##..##..##....",
      "..##..#..#.#....#....#..#.#...#...#....",
      ".#.#..#...#.#...##...#...#.#..##..##...",
      "..#...##...#.#.#.#...##...#....#...#...",
      "..##.#.#....#####.#.#.#...##...##..##..",
      ".#..###.#..#.#.#######.#.#.#..#.#...#..",
      ".#....##....#####...#######....#.#..##.",
    ]
    {pots, n_pots} = InputParser.parse_initial_state("initial state: #..#.#..##......###...###\n")
    generations
    |> Enum.reduce({1, pots}, fn (expect_gen, {n, pots}) ->
      next_pots = Plants.next_generation(pots, n_pots, rules)
      next_gen = Plants.render_state(next_pots, -3..35)
      assert {n, next_gen} == {n, expect_gen}
      {n+1, next_pots}
    end)
  end
end
