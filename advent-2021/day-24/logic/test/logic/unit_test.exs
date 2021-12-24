defmodule Logic.UnitTest do
  use ExUnit.Case
  doctest Logic.Unit

  alias Logic.Unit, as: Unit

  describe "puzzle example" do
    setup do
      [
        # "an ALU program which takes two input numbers, then sets z to 1
        # if the second input number is three times larger than the first
        # input number, or sets z to 0 otherwise"
        program2: [
          {:inp, :z},
          {:inp, :x},
          {:mul, :z, 3},
          {:eql, :z, :x},
        ],
        # "an ALU program which takes a non-negative integer as input,
        # converts it into binary, and stores the lowest (1's) bit in z,
        # the second-lowest (2's) bit in y, the third-lowest (4's) bit in x,
        # and the fourth-lowest (8's) bit in w"
        program3: [
          {:inp, :w},
          {:add, :z, :w},
          {:mod, :z, 2},
          {:div, :w, 2},
          {:add, :y, :w},
          {:mod, :y, 2},
          {:div, :w, 2},
          {:add, :x, :w},
          {:mod, :x, 2},
          {:div, :w, 2},
          {:mod, :w, 2},
        ],
        # an ALU program which plays the "21 matchsticks" game
        # 1. x starts with 21 matches
        # 2. human (via input) removes 1, 2, or 3 matchsticks
        #    (by entering 1, 2, or 3)
        # 3. computer removes 1, 2, or 3 matchsticks
        # 4. steps 2 and 3 repeat
        # 5. eventually x will be 1; human (via input) is forced
        #    to remove the last matchstick, and loses the game
        matchsticks: [
          {:add, :x, 21},
          # 21
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 17
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 13
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 9
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 5
          {:inp, :w},
          {:mul, :z, 0},
          {:add, :z, -4},
          {:add, :z, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
          {:add, :x, :z},
          # 1
          {:inp, :w},
          {:mul, :w, -1},
          {:add, :x, :w},
        ],
      ]
    end

    test "executor gets expected results (program 2)", fixture do
      assert {_, _, _, 1} = Unit.run(fixture.program2, [1, 3])
      assert {_, _, _, 0} = Unit.run(fixture.program2, [2, 5])
      assert {_, _, _, 1} = Unit.run(fixture.program2, [2, 6])
      assert {_, _, _, 0} = Unit.run(fixture.program2, [2, 7])
      assert {_, _, _, 1} = Unit.run(fixture.program2, [81, 243])
    end

    test "executor gets expected results (program 3)", fixture do
      assert {0, 0, 0, 0} = Unit.run(fixture.program3, [0])
      assert {0, 0, 0, 1} = Unit.run(fixture.program3, [1])
      assert {0, 0, 1, 0} = Unit.run(fixture.program3, [2])
      assert {0, 1, 0, 0} = Unit.run(fixture.program3, [4])
      assert {0, 1, 0, 1} = Unit.run(fixture.program3, [5])
      assert {0, 1, 1, 0} = Unit.run(fixture.program3, [6])
      assert {1, 0, 0, 1} = Unit.run(fixture.program3, [9])
      assert {1, 1, 1, 1} = Unit.run(fixture.program3, [15])
    end

    test "executor gets expected results (matchsticks)", fixture do
      assert {_, 0, _, _} = Unit.run(fixture.matchsticks, [1, 2, 3, 1, 2, 1])
      assert {_, 0, _, _} = Unit.run(fixture.matchsticks, [2, 3, 1, 2, 3, 1])
      assert {_, 0, _, _} = Unit.run(fixture.matchsticks, [3, 1, 2, 3, 1, 1])
      assert {_, 0, _, _} = Unit.run(fixture.matchsticks, [2, 1, 3, 1, 2, 1])
      assert {_, 0, _, _} = Unit.run(fixture.matchsticks, [3, 2, 1, 3, 2, 1])
    end
  end
end
