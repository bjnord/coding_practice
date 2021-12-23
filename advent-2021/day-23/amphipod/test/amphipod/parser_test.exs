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
        exp_input_amphipos: [
          {1, {3, 1}},
          {2, {5, 1}},
          {1, {7, 1}},
          {3, {9, 1}},
          {0, {3, 0}},
          {3, {5, 0}},
          {2, {7, 0}},
          {0, {9, 0}},
        ],
        tiny: """
        #######
        #.....#
        ##A#B##
         #B#A#
         #####
        """,
        exp_tiny_amphipos: [
          {0, {2, 1}},
          {1, {4, 1}},
          {1, {2, 0}},
          {0, {4, 0}},
        ],
      ]
    end

    test "parser gets expected amphipositions (tiny)", fixture do
      assert Parser.parse(fixture.tiny) == fixture.exp_tiny_amphipos
    end

    test "parser gets expected amphipositions (input)", fixture do
      assert Parser.parse(fixture.input) == fixture.exp_input_amphipos
    end
  end
end
