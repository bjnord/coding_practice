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
      ]
    end

    test "calculate calibration values (part 1 rules)", fixture do
      act_part1_values = fixture.part1_entries
                         |> Enum.map(&Value.naïve_value/1)
      assert act_part1_values == fixture.exp_part1_values
    end
  end

end
