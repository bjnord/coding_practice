defmodule Mirror.ParserTest do
  use ExUnit.Case
  doctest Mirror.Parser, import: true

  import Mirror.Parser

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
        """,
        exp_dimensions: [
          {7, 9},
          {7, 9},
        ],
      ]
    end

    test "parser gets expected dimensions", fixture do
      act_dimensions = fixture.input
                       |> parse_input_string()
                       |> Enum.map(fn image -> {image.y, image.x} end)
      assert act_dimensions == fixture.exp_dimensions
    end

    test "parser gets expected row/col lengths", fixture do
      act_row_col_len =
        fixture.input
        |> parse_input_string()
        |> Enum.map(fn image ->
          {
            Enum.count(image.rows),
            Enum.count(image.cols),
          }
        end)
      assert act_row_col_len == fixture.exp_dimensions
    end
  end
end
