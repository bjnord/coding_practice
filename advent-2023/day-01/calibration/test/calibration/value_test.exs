defmodule Calibration.ValueTest do
  use ExUnit.Case
  doctest Calibration.Value

  alias Calibration.Value, as: Value

  describe "puzzle example" do
    setup do
      [
        part1_entries: [
          '1abc2',
          'pqr3stu8vwx',
          'a1b2c3d4e5f',
          'treb7uchet',
        ],
        exp_part1_values: [
          12,
          38,
          15,
          77,
        ],
        part2_entries: [
          'two1nine',
          'eightwothree',
          'abcone2threexyz',
          'xtwone3four',
          '4nineeightseven2',
          'zoneight234',
          '7pqrstsixteen',
        ],
        exp_part2_values: [
          29,
          83,
          13,
          24,
          42,
          14,
          76,
        ],
      ]
    end

    test "calculate calibration values (part 1 rules)", fixture do
      act_part1_values = fixture.part1_entries
                         |> Enum.map(&Value.naïve_value/1)
      assert act_part1_values == fixture.exp_part1_values
    end

    test "calculate calibration values (part 2 rules)", fixture do
      act_part2_values = fixture.part2_entries
                         |> Enum.map(&Value.value/1)
      assert act_part2_values == fixture.exp_part2_values
    end
  end
end
