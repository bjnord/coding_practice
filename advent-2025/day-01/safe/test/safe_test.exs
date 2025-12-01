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
        exp_positions: [
          {"L68", -68, 82},
          {"L30", -30, 52},
          {"R48",  48,  0},
          {"L5",   -5, 95},
          {"R60",  60, 55},
          {"L55", -55,  0},
          {"L1",   -1, 99},
          {"L99", -99,  0},
          {"R14",  14, 14},
          {"L82", -82, 32},
        ],
      ]
    end

    test "rotate gets expected positions", fixture do
      act_positions = fixture.rotations
                      |> rotate()
      assert act_positions == fixture.exp_positions
    end
  end
end
