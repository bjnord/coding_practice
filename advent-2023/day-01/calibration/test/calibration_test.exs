defmodule CalibrationTest do
  use ExUnit.Case
  doctest Calibration

  describe "puzzle example" do
    setup do
      [
        entries: [
          '1abc2',
          'pqr3stu8vwx',
          'a1b2c3d4e5f',
          'treb7uchet',
        ],
        exp_calibration_values: [
          12,
          38,
          15,
          77,
        ],
      ]
    end

    test "calculate calibration values", fixture do
      act_values = fixture.entries
                   |> Enum.map(&Calibration.value/1)
      assert act_values == fixture.exp_calibration_values
    end
  end
end
