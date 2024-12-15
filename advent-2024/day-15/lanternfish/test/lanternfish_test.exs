defmodule LanternfishTest do
  use ExUnit.Case
  doctest Lanternfish

  alias History.Grid
  import Lanternfish.Parser

  describe "puzzle example" do
    setup do
      [
        grid: %Grid{
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
        directions: [
          :west, :north, :north, :east, :east, :east, :south, :south,
          :west, :south, :east, :east, :south, :west, :west,
        ],
        exp_move_dumps: [
          """
          ########
          #..O.O.#
          ##@.O..#
          #...O..#
          #.#.O..#
          #...O..#
          #......#
          ########
          """,
          """
          ########
          #..O.O.#
          ##@.O..#
          #...O..#
          #.#.O..#
          #...O..#
          #......#
          ########
          """,
          """
          ########
          #.@O.O.#
          ##..O..#
          #...O..#
          #.#.O..#
          #...O..#
          #......#
          ########
          """,
          """
          ########
          #.@O.O.#
          ##..O..#
          #...O..#
          #.#.O..#
          #...O..#
          #......#
          ########
          """,
          """
          ########
          #..@OO.#
          ##..O..#
          #...O..#
          #.#.O..#
          #...O..#
          #......#
          ########
          """,
          """
          ########
          #...@OO#
          ##..O..#
          #...O..#
          #.#.O..#
          #...O..#
          #......#
          ########
          """,
          """
          ########
          #...@OO#
          ##..O..#
          #...O..#
          #.#.O..#
          #...O..#
          #......#
          ########
          """,
          """
          ########
          #....OO#
          ##..@..#
          #...O..#
          #.#.O..#
          #...O..#
          #...O..#
          ########
          """,
          """
          ########
          #....OO#
          ##..@..#
          #...O..#
          #.#.O..#
          #...O..#
          #...O..#
          ########
          """,
          """
          ########
          #....OO#
          ##.@...#
          #...O..#
          #.#.O..#
          #...O..#
          #...O..#
          ########
          """,
          """
          ########
          #....OO#
          ##.....#
          #..@O..#
          #.#.O..#
          #...O..#
          #...O..#
          ########
          """,
          """
          ########
          #....OO#
          ##.....#
          #...@O.#
          #.#.O..#
          #...O..#
          #...O..#
          ########
          """,
          """
          ########
          #....OO#
          ##.....#
          #....@O#
          #.#.O..#
          #...O..#
          #...O..#
          ########
          """,
          """
          ########
          #....OO#
          ##.....#
          #.....O#
          #.#.O@.#
          #...O..#
          #...O..#
          ########
          """,
          """
          ########
          #....OO#
          ##.....#
          #.....O#
          #.#O@..#
          #...O..#
          #...O..#
          ########
          """,
          """
          ########
          #....OO#
          ##.....#
          #.....O#
          #.#O@..#
          #...O..#
          #...O..#
          ########
          """,
        ],
        exp_gps: 2028,
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
        exp_move_dump2: """
        ##########
        #.O.O.OOO#
        #........#
        #OO......#
        #OO@.....#
        #O#.....O#
        #O.....OO#
        #O.....OO#
        #OO....OO#
        ##########
        """,
        exp_gps2: 10092,
        input3: """
        #######
        #...#.#
        #.....#
        #..OO@#
        #..O..#
        #.....#
        #######

        <vv<<^^<<^^
        """,
        exp_move_dumps3: [
          """
          ##############
          ##......##..##
          ##..........##
          ##....[][]@.##
          ##....[]....##
          ##..........##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##..........##
          ##...[][]@..##
          ##....[]....##
          ##..........##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##..........##
          ##...[][]...##
          ##....[].@..##
          ##..........##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##..........##
          ##...[][]...##
          ##....[]....##
          ##.......@..##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##..........##
          ##...[][]...##
          ##....[]....##
          ##......@...##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##..........##
          ##...[][]...##
          ##....[]....##
          ##.....@....##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##...[][]...##
          ##....[]....##
          ##.....@....##
          ##..........##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##...[][]...##
          ##....[]....##
          ##.....@....##
          ##..........##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##...[][]...##
          ##....[]....##
          ##....@.....##
          ##..........##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##...[][]...##
          ##....[]....##
          ##...@......##
          ##..........##
          ##############
          """,
          """
          ##############
          ##......##..##
          ##...[][]...##
          ##...@[]....##
          ##..........##
          ##..........##
          ##############
          """,
          """
          ##############
          ##...[].##..##
          ##...@.[]...##
          ##....[]....##
          ##..........##
          ##..........##
          ##############
          """,
        ],
        exp_move_dump2w: """
        ####################
        ##[].......[].[][]##
        ##[]...........[].##
        ##[]........[][][]##
        ##[]......[]....[]##
        ##..##......[]....##
        ##..[]............##
        ##..@......[].[][]##
        ##......[][]..[]..##
        ####################
        """,
        exp_gps2w: 9021,
      ]
    end

    test "produces correct box movements (example 1)", fixture do
      act_move_dumps =
        Lanternfish.movements({fixture.grid, fixture.directions})
        |> Enum.reverse()
        |> Enum.map(&Lanternfish.dump_string/1)
      assert act_move_dumps == fixture.exp_move_dumps
    end

    test "produces correct GPS (example 1)", fixture do
      act_gps =
        Lanternfish.movements({fixture.grid, fixture.directions})
        |> List.first()
        |> Lanternfish.gps()
      assert act_gps == fixture.exp_gps
    end

    test "produces correct box movements (example 2)", fixture do
      act_move_dump2 =
        parse_input_string(fixture.input2)
        |> Lanternfish.movements()
        |> List.first()
        |> Lanternfish.dump_string()
      assert act_move_dump2 == fixture.exp_move_dump2
    end

    test "produces correct GPS (example 2)", fixture do
      act_gps2 =
        parse_input_string(fixture.input2)
        |> Lanternfish.movements()
        |> List.first()
        |> Lanternfish.gps()
      assert act_gps2 == fixture.exp_gps2
    end

    test "produces correct box movements (part 2, example 3)", fixture do
      act_move_dumps3 =
        parse_input_string(fixture.input3, wide: true)
        |> Lanternfish.movements()
        |> Enum.reverse()
        |> Enum.map(&Lanternfish.dump_string/1)
      assert act_move_dumps3 == fixture.exp_move_dumps3
    end

    test "produces correct box movements (part 2, example 2)", fixture do
      act_move_dump2w =
        parse_input_string(fixture.input2, wide: true)
        |> Lanternfish.movements()
        |> List.first()
        |> Lanternfish.dump_string()
      assert act_move_dump2w == fixture.exp_move_dump2w
    end

    test "produces correct GPS (part 2, example 2)", fixture do
      act_gps2w =
        parse_input_string(fixture.input2, wide: true)
        |> Lanternfish.movements()
        |> List.first()
        |> Lanternfish.gps()
      assert act_gps2w == fixture.exp_gps2w
    end
  end
end
