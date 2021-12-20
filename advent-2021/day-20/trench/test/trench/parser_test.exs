defmodule Trench.ParserTest do
  use ExUnit.Case
  doctest Trench.Parser

  alias Trench.Parser, as: Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

        #..#.
        #....
        ##..#
        ..#..
        ..###
        """,
        exp_algor_34: 1,
        exp_algor_zeroes: 274,
        exp_algor_ones: 238,
        exp_radius: 2,
        exp_pixmap: %{
          {-2, -2} => 1, {-1, -2} => 0, { 0, -2} => 0, { 1, -2} => 1, { 2, -2} => 0,
          {-2, -1} => 1, {-1, -1} => 0, { 0, -1} => 0, { 1, -1} => 0, { 2, -1} => 0,
          {-2,  0} => 1, {-1,  0} => 1, { 0,  0} => 0, { 1,  0} => 0, { 2,  0} => 1,
          {-2,  1} => 0, {-1,  1} => 0, { 0,  1} => 1, { 1,  1} => 0, { 2,  1} => 0,
          {-2,  2} => 0, {-1,  2} => 0, { 0,  2} => 1, { 1,  2} => 1, { 2,  2} => 1,
        },
      ]
    end

    def count_of(map, v) do
      Map.values(map)
      |> Enum.count(&(&1 == v))
    end

    test "parser gets expected algorithm, radius, and pixmap", fixture do
      {act_algor, {act_radius, act_pixmap}} = Parser.parse(fixture.input)
      assert act_algor[34] == fixture.exp_algor_34
      assert count_of(act_algor, 0) == fixture.exp_algor_zeroes
      assert count_of(act_algor, 1) == fixture.exp_algor_ones
      assert act_radius == fixture.exp_radius
      assert act_pixmap == fixture.exp_pixmap
    end
  end
end
