defmodule Segment.ParserTest do
  use ExUnit.Case
  doctest Segment.Parser

  describe "puzzle example" do
    setup do
      [
        input_line: "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf",
        exp_note: {
          ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab'],
          ['bcdef', 'abcdf', 'bcdef', 'abcdf'],
        },
      ]
    end

    test "parser gets expected note", fixture do
      assert Segment.Parser.parse_line(fixture.input_line) == fixture.exp_note
    end
  end
end
