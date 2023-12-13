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
        exp_smudged_reflections: [
          {:horiz, 3},
          {:horiz, 1},
        ],
      ]
    end

    test "find image reflections", fixture do
      act_reflections = fixture.input
                        |> parse_input_string()
                        |> Enum.map(&Image.reflection/1)
      assert act_reflections == fixture.exp_reflections
    end

    test "find smudged image reflections", fixture do
      act_smudged_reflections =
        fixture.input
        |> parse_input_string()
        |> Enum.take(2)
        |> Enum.map(&Image.smudged_reflection/1)
      assert act_smudged_reflections == fixture.exp_smudged_reflections
    end
  end
end
