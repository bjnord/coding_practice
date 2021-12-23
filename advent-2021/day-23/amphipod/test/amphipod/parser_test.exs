defmodule Amphipod.ParserTest do
  use ExUnit.Case
  doctest Amphipod.Parser

  alias Amphipod.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        #############
        #...........#
        ###B#C#B#D###
          #A#D#C#A#
          #########
        """,
        exp_amphipos: [
          {:bronze, {3, 1}},
          {:copper, {5, 1}},
          {:bronze, {7, 1}},
          {:desert, {9, 1}},
          {:amber,  {3, 0}},
          {:desert, {5, 0}},
          {:copper, {7, 0}},
          {:amber,  {9, 0}},
        ],
      ]
    end

    test "parser gets expected amphipositions", fixture do
      assert Parser.parse(fixture.input) == fixture.exp_amphipos
    end
  end
end
