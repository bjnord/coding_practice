defmodule Compact.ParserTest do
  use ExUnit.Case
  doctest Compact.Parser, import: true

  import Compact.Parser

  describe "puzzle example" do
    setup do
      [
        inputs: [
          "12345",
          "2333133121414131402",
        ],
        exp_layouts: [
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
      ]
    end

    test "parser gets expected layouts", fixture do
      act_layouts = fixture.inputs
                    |> Enum.map(&parse_input_string/1)
      assert act_layouts == fixture.exp_layouts
    end
  end
end
