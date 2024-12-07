defmodule BridgeTest do
  use ExUnit.Case
  doctest Bridge, import: true

  describe "puzzle example" do
    setup do
      [
        equations: [
          {190, [10, 19]},
          {3267, [81, 40, 27]},
          {83, [17, 5]},
          {156, [15, 6]},
          {7290, [6, 8, 6, 15]},
          {161011, [16, 10, 13]},
          {192, [17, 8, 14]},
          {21037, [9, 7, 18, 13]},
          {292, [11, 6, 16, 20]},
        ],
        exp_solvables: [
          true,
          true,
          false,
          false,
          false,
          false,
          false,
          false,
          true,
        ],
        exp_solvables3: [
          true,
          true,
          false,
          true,
          true,
          false,
          true,
          false,
          true,
        ],
      ]
    end

    test "finds solvable equations (2 operators)", fixture do
      act_solvables = fixture.equations
                      |> Enum.map(&Bridge.atom_solvable?/1)
      assert act_solvables == fixture.exp_solvables
    end

    test "finds solvable equations (3 operators)", fixture do
      act_solvables3 = fixture.equations
                       |> Enum.map(&Bridge.atom_solvable3?/1)
      assert act_solvables3 == fixture.exp_solvables3
    end
  end
end
