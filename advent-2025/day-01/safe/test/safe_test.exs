defmodule SafeTest do
  use ExUnit.Case
  doctest Safe

  import Safe

  describe "puzzle example" do
    setup do
      [
        rotations: [
          {"L68", -68},
          {"L30", -30},
          {"R48",  48},
          {"L5",   -5},
          {"R60",  60},
          {"L55", -55},
          {"L1",   -1},
          {"L99", -99},
          {"R14",  14},
          {"L82", -82},
        ],
        exp_pos_and_clicks: [
          {"L68", -68, 82, 1},
          {"L30", -30, 52, 0},
          {"R48",  48,  0, 1},
          {"L5",   -5, 95, 0},
          {"R60",  60, 55, 1},
          {"L55", -55,  0, 1},
          {"L1",   -1, 99, 0},
          {"L99", -99,  0, 1},
          {"R14",  14, 14, 0},
          {"L82", -82, 32, 1},
        ],
      ]
    end

    test "rotate gets expected positions and clicks", fixture do
      act_pos_and_clicks = fixture.rotations
                           |> rotate()
      assert act_pos_and_clicks == fixture.exp_pos_and_clicks
    end
  end
end
