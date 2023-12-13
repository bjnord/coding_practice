defmodule Mirror.ImageTest do
  use ExUnit.Case
  doctest Mirror.Image, import: true

  import Mirror.Parser
  alias Mirror.Image

  describe "puzzle example" do
    setup do
      [
        input: """
        #.##..##.
        ..#.##.#.
        ##......#
        ##......#
        ..#.##.#.
        ..##..##.
        #.#.##.#.

        #...##..#
        #....#..#
        ..##..###
        #####.##.
        #####.##.
        ..##..###
        #....#..#

        #.####..#.#
        #..###..#.#
        #...##..#.#
        #....#..#.#
        ..##..###.#
        #####.##..#
        #####.##..#
        ..##..###.#
        #....#..#.#
        """,
        exp_reflections: [
          {:vert, 5},
          {:horiz, 4},
          {:horiz, 6},
        ],
      ]
    end

    test "find image reflections", fixture do
      act_reflections = fixture.input
                        |> parse_input_string()
                        |> Enum.map(&Image.reflection/1)
      assert act_reflections == fixture.exp_reflections
    end
  end
end
