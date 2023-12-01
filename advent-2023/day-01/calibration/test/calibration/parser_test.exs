defmodule Calibration.ParserTest do
  use ExUnit.Case
  doctest Calibration.Parser

  alias Calibration.Parser, as: Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        1abc2
        pqr3stu8vwx
        a1b2c3d4e5f
        treb7uchet
        two1nine
        eightwothree
        abcone2threexyz
        xtwone3four
        4nineeightseven2
        zoneight234
        7pqrstsixteen
        """,
        exp_charlists: [
          '1abc2',
          'pqr3stu8vwx',
          'a1b2c3d4e5f',
          'treb7uchet',
          'two1nine',
          'eightwothree',
          'abcone2threexyz',
          'xtwone3four',
          '4nineeightseven2',
          'zoneight234',
          '7pqrstsixteen',
        ],
      ]
    end

    test "parser gets expected charlists", fixture do
      assert Parser.parse(fixture.input) == fixture.exp_charlists
    end
  end
end
