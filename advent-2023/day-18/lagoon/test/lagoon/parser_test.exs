defmodule Lagoon.ParserTest do
  use ExUnit.Case
  doctest Lagoon.Parser, import: true

  import Lagoon.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        R 6 (#70c710)
        D 5 (#0dc571)
        L 2 (#5713f0)
        D 2 (#d2c081)
        R 2 (#59c680)
        D 2 (#411b91)
        L 5 (#8ceee2)
        U 2 (#caa173)
        L 1 (#1b58a2)
        U 2 (#caa171)
        R 2 (#7807d2)
        U 3 (#a77fa3)
        L 2 (#015232)
        U 2 (#7a21e3)
        """,
        exp_entries_part1: [
          {:right, 6, 0x70c710},
          {:down, 5, 0x0dc571},
          {:left, 2, 0x5713f0},
          {:down, 2, 0xd2c081},
          {:right, 2, 0x59c680},
          {:down, 2, 0x411b91},
          {:left, 5, 0x8ceee2},
          {:up, 2, 0xcaa173},
          {:left, 1, 0x1b58a2},
          {:up, 2, 0xcaa171},
          {:right, 2, 0x7807d2},
          {:up, 3, 0xa77fa3},
          {:left, 2, 0x015232},
          {:up, 2, 0x7a21e3},
        ],
        exp_entries_part2: [
          {:right, 461937, 0x70c710},
          {:down, 56407, 0x0dc571},
          {:right, 356671, 0x5713f0},
          {:down, 863240, 0xd2c081},
          {:right, 367720, 0x59c680},
          {:down, 266681, 0x411b91},
          {:left, 577262, 0x8ceee2},
          {:up, 829975, 0xcaa173},
          {:left, 112010, 0x1b58a2},
          {:down, 829975, 0xcaa171},
          {:left, 491645, 0x7807d2},
          {:up, 686074, 0xa77fa3},
          {:left, 5411, 0x015232},
          {:up, 500254, 0x7a21e3},
        ],
      ]
    end

    test "parser gets expected entries (part 1)", fixture do
      act_entries_part1 = fixture.input
                          |> parse_input_string(part: 1)
                          |> Enum.to_list()
      assert act_entries_part1 == fixture.exp_entries_part1
    end

    test "parser gets expected entries (part 2)", fixture do
      act_entries_part2 = fixture.input
                          |> parse_input_string(part: 2)
                          |> Enum.to_list()
      assert act_entries_part2 == fixture.exp_entries_part2
    end
  end
end
