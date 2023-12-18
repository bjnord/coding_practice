defmodule LagoonTest do
  use ExUnit.Case
  doctest Lagoon

  describe "puzzle example" do
    setup do
      [
        instructions: [
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
        exp_lagoon_border_size: 38,
        exp_lagoon_size: 62,
      ]
    end

    test "find lagoon border size", fixture do
      act_lagoon_border_size = fixture.instructions
                               |> Lagoon.border_size()
      assert act_lagoon_border_size == fixture.exp_lagoon_border_size
    end
  end
end
