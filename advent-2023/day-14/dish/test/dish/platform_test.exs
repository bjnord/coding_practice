defmodule Dish.PlatformTest do
  use ExUnit.Case
  doctest Dish.Platform, import: true

  import Dish.Parser
  alias Dish.Platform

  describe "puzzle example" do
    setup do
      [
        platform: %Platform{
          rocks: %{
            {0, 0} => :O,
            {0, 5} => :M,
            {1, 0} => :O,
            {1, 2} => :O,
            {1, 3} => :O,
            {1, 4} => :M,
            {1, 9} => :M,
            {2, 5} => :M,
            {2, 6} => :M,
            {3, 0} => :O,
            {3, 1} => :O,
            {3, 3} => :M,
            {3, 4} => :O,
            {3, 9} => :O,
            {4, 1} => :O,
            {4, 7} => :O,
            {4, 8} => :M,
            {5, 0} => :O,
            {5, 2} => :M,
            {5, 5} => :O,
            {5, 7} => :M,
            {5, 9} => :M,
            {6, 2} => :O,
            {6, 5} => :M,
            {6, 6} => :O,
            {6, 9} => :O,
            {7, 7} => :O,
            {8, 0} => :M,
            {8, 5} => :M,
            {8, 6} => :M,
            {8, 7} => :M,
            {9, 0} => :M,
            {9, 1} => :O,
            {9, 2} => :O,
            {9, 5} => :M,
          },
          size: {10, 10},
          tilt: :flat,
        },
        exp_n_platform: %Platform{
          rocks: %{
            {0, 0} => :O,
            {0, 1} => :O,
            {0, 2} => :O,
            {0, 3} => :O,
            {0, 5} => :M,
            {0, 7} => :O,
            {1, 0} => :O,
            {1, 1} => :O,
            {1, 4} => :M,
            {1, 9} => :M,
            {2, 0} => :O,
            {2, 1} => :O,
            {2, 4} => :O,
            {2, 5} => :M,
            {2, 6} => :M,
            {2, 9} => :O,
            {3, 0} => :O,
            {3, 3} => :M,
            {3, 5} => :O,
            {3, 6} => :O,
            {4, 8} => :M,
            {5, 2} => :M,
            {5, 7} => :M,
            {5, 9} => :M,
            {6, 2} => :O,
            {6, 5} => :M,
            {6, 7} => :O,
            {6, 9} => :O,
            {7, 2} => :O,
            {8, 0} => :M,
            {8, 5} => :M,
            {8, 6} => :M,
            {8, 7} => :M,
            {9, 0} => :M,
            {9, 5} => :M,
          },
          size: {10, 10},
          tilt: :north,
        },
        exp_n_load: 136,
        exp_part2_cycles: [
          # After 1 cycle:
          """
          .....#....
          ....#...O#
          ...OO##...
          .OO#......
          .....OOO#.
          .O#...O#.#
          ....O#....
          ......OOOO
          #...O###..
          #..OO#....
          """,
          # After 2 cycles:
          """
          .....#....
          ....#...O#
          .....##...
          ..O#......
          .....OOO#.
          .O#...O#.#
          ....O#...O
          .......OOO
          #..OO###..
          #.OOO#...O
          """,
          # After 3 cycles:
          """
          .....#....
          ....#...O#
          .....##...
          ..O#......
          .....OOO#.
          .O#...O#.#
          ....O#...O
          .......OOO
          #...O###.O
          #.OOO#...O
          """,
        ],
      ]
    end

    test "tilt N", fixture do
      act_n_platform = fixture.platform
                       |> Platform.tilt(:north)
      assert act_n_platform == fixture.exp_n_platform
    end

    test "find N load", fixture do
      act_n_load = fixture.exp_n_platform
                   |> Platform.load(:north)
      assert act_n_load == fixture.exp_n_load
    end

    test "cycle", fixture do
      fixture.exp_part2_cycles
      |> Enum.reduce(fixture.platform, fn exp_cycle_input, platform ->
        exp_cycled =
          parse_input_string(exp_cycle_input)
          |> then(fn platform -> %Platform{platform | tilt: :east} end)
        new_platform = Platform.cycle(platform)
        assert new_platform == exp_cycled
        new_platform
      end)
    end
  end
end
