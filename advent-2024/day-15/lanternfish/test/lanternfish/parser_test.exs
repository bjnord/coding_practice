defmodule Lanternfish.ParserTest do
  use ExUnit.Case
  doctest Lanternfish.Parser, import: true

  import Lanternfish.Parser
  alias History.Grid

  describe "puzzle example" do
    setup do
      [
        input: """
        ########
        #..O.O.#
        ##@.O..#
        #...O..#
        #.#.O..#
        #...O..#
        #......#
        ########

        <^^>>>vv
        <v>>v<<
        """,
        exp_grid: %Grid{
          size: %{y: 8, x: 8},
          squares: %{
            {0, 0} => ?#, {0, 1} => ?#, {0, 2} => ?#, {0, 3} => ?#,
            {0, 4} => ?#, {0, 5} => ?#, {0, 6} => ?#, {0, 7} => ?#,
            {1, 0} => ?#, {1, 3} => ?O, {1, 5} => ?O, {1, 7} => ?#,
            {2, 0} => ?#, {2, 1} => ?#, {2, 4} => ?O, {2, 7} => ?#,
            {3, 0} => ?#, {3, 4} => ?O, {3, 7} => ?#,
            {4, 0} => ?#, {4, 2} => ?#, {4, 4} => ?O, {4, 7} => ?#,
            {5, 0} => ?#, {5, 4} => ?O, {5, 7} => ?#,
            {6, 0} => ?#, {6, 7} => ?#,
            {7, 0} => ?#, {7, 1} => ?#, {7, 2} => ?#, {7, 3} => ?#,
            {7, 4} => ?#, {7, 5} => ?#, {7, 6} => ?#, {7, 7} => ?#,
          },
          meta: %{start: {2, 2}},
        },
        exp_directions: [
          :west, :north, :north, :east, :east, :east, :south, :south,
          :west, :south, :east, :east, :south, :west, :west,
        ],
        input2: """
        ##########
        #..O..O.O#
        #......O.#
        #.OO..O.O#
        #..O@..O.#
        #O#..O...#
        #O..O..O.#
        #.OO.O.OO#
        #....O...#
        ##########

        <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
        vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
        ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
        <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
        ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
        ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
        >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
        <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
        ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
        v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
        """,
        exp_dump2: """
        ####################
        ##....[]....[]..[]##
        ##............[]..##
        ##..[][]....[]..[]##
        ##....[]@.....[]..##
        ##[]##....[]......##
        ##[]....[]....[]..##
        ##..[][]..[]..[][]##
        ##........[]......##
        ####################
        """,
      ]
    end

    test "produces correct grid (example 1)", fixture do
      {act_grid, act_directions} =
        fixture.input
        |> parse_input_string()
      assert act_grid == fixture.exp_grid
      assert act_directions == fixture.exp_directions
    end

    test "produces correct grid (example 2)", fixture do
      act_grid2 =
        fixture.input2
        |> parse_input_string(wide: true)
        |> elem(0)
      act_dump2 = Lanternfish.dump_string({act_grid2, act_grid2.meta.start})
      assert act_dump2 == fixture.exp_dump2
    end
  end
end
