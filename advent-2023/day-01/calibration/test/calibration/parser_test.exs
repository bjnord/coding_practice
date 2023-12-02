defmodule Calibration.ParserTest do
  use ExUnit.Case
  doctest Calibration.Parser, import: true

  import Calibration.Parser

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
      act_charlists = fixture.input
                      |> parse_input_string()
                      |> Enum.to_list()
      assert act_charlists == fixture.exp_charlists
    end
  end
end
