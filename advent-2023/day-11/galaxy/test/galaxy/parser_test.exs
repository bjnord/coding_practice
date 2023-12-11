defmodule Galaxy.ParserTest do
  use ExUnit.Case
  doctest Galaxy.Parser, import: true

  import Galaxy.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        ...#......
        .......#..
        #.........
        ..........
        ......#...
        .#........
        .........#
        ..........
        .......#..
        #...#.....
        """,
        exp_image: [
          {0, 3},
          {1, 7},
          {2, 0},
          {4, 6},
          {5, 1},
          {6, 9},
          {8, 7},
          {9, 0},
          {9, 4},
        ],
      ]
    end

    test "parser gets expected image", fixture do
      act_images = fixture.input
                   |> parse_input_string()
      assert act_images == fixture.exp_image
    end
  end
end
