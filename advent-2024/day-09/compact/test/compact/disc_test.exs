defmodule Compact.DiscTest do
  use ExUnit.Case
  doctest Compact.Disc, import: true

  alias Compact.Disc

  describe "puzzle example" do
    setup do
      [
        layouts: [
          [
            {:file, 1, 0},
            {:space, 2},
            {:file, 3, 1},
            {:space, 4},
            {:file, 5, 2},
          ],
          [
            {:file, 2, 0},
            {:space, 3},
            {:file, 3, 1},
            {:space, 3},
            {:file, 1, 2},
            {:space, 3},
            {:file, 3, 3},
            {:space, 1},
            {:file, 2, 4},
            {:space, 1},
            {:file, 4, 5},
            {:space, 1},
            {:file, 4, 6},
            {:space, 1},
            {:file, 3, 7},
            {:space, 1},
            {:file, 4, 8},
            {:space, 0},
            {:file, 2, 9},
          ],
        ],
        exp_strings: [
          "0..111....22222",
          "00...111...2...333.44.5555.6666.777.888899",
        ],
        exp_compacts: [
          "022111222......",
          "0099811188827773336446555566..............",
        ],
      ]
    end

    test "produces expected layout strings", fixture do
      act_strings = fixture.layouts
                    |> Enum.map(&Disc.create/1)
                    |> Enum.map(&Disc.to_string/1)
      assert act_strings == fixture.exp_strings
    end

    test "produces expected compactions", fixture do
      act_compacts = fixture.layouts
                     |> Enum.map(&Disc.create/1)
                     |> Enum.map(&Disc.compact/1)
                     |> Enum.map(&Disc.to_string/1)
      assert act_compacts == fixture.exp_compacts
    end
  end
end
