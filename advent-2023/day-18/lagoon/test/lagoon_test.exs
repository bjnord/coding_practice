defmodule LagoonTest do
  use ExUnit.Case
  doctest Lagoon

  describe "puzzle example" do
    setup do
      [
        instructions_part1: [
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
        exp_lagoon_size_part1: 62,
        instructions_part2: [
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
        exp_lagoon_size_part2: 952408144115,
      ]
    end

    test "find lagoon size (part 1)", fixture do
      act_lagoon_size_part1 = fixture.instructions_part1
                              |> Lagoon.lagoon_size()
      assert act_lagoon_size_part1 == fixture.exp_lagoon_size_part1
    end

    test "find lagoon size (part 2)", fixture do
      act_lagoon_size_part2 = fixture.instructions_part2
                              |> Lagoon.lagoon_size()
      assert act_lagoon_size_part2 == fixture.exp_lagoon_size_part2
    end
  end
end
