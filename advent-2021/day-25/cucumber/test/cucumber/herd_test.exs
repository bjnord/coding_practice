defmodule Cucumber.HerdTest do
  use ExUnit.Case
  doctest Cucumber.Herd

  alias Cucumber.Herd

  describe "puzzle example" do
    setup do
      [
        ex1_initial: """
        ...>...
        .......
        ......>
        v.....>
        ......>
        .......
        ..vvv..
        """,
        exp_ex1_initial_matrix: {
          {:floor, :floor, :floor, :east,  :floor, :floor, :floor},
          {:floor, :floor, :floor, :floor, :floor, :floor, :floor},
          {:floor, :floor, :floor, :floor, :floor, :floor, :east },
          {:south, :floor, :floor, :floor, :floor, :floor, :east },
          {:floor, :floor, :floor, :floor, :floor, :floor, :east },
          {:floor, :floor, :floor, :floor, :floor, :floor, :floor},
          {:floor, :floor, :south, :south, :south, :floor, :floor},
        },
        exp_ex1_initial_east: [{3, 0}, {6, 2}, {6, 3}, {6, 4}],
        exp_ex1_initial_south: [{0, 3}, {2, 6}, {3, 6}, {4, 6}],
        ex1_steps: 4,
        ex1_final: """
        >......
        ..v....
        ..>.v..
        .>.v...
        ...>...
        .......
        v......
        """,
        exp_ex1_final_matrix: {
          {:east,  :floor, :floor, :floor, :floor, :floor, :floor},
          {:floor, :floor, :south, :floor, :floor, :floor, :floor},
          {:floor, :floor, :east,  :floor, :south, :floor, :floor},
          {:floor, :east,  :floor, :south, :floor, :floor, :floor},
          {:floor, :floor, :floor, :east,  :floor, :floor, :floor},
          {:floor, :floor, :floor, :floor, :floor, :floor, :floor},
          {:south, :floor, :floor, :floor, :floor, :floor, :floor},
        },
        exp_ex1_final_east: [{0, 0}, {1, 3}, {2, 2}, {3, 4}],
        exp_ex1_final_south: [{0, 6}, {2, 1}, {3, 3}, {4, 2}],
        uneven_widths: """
        ...>...
        .......
        ......>
        v.....>
        ......>
        .......
        ..vvv.
        """,
        ex2_initial: """
        v...>>.vv>
        .vv>>.vv..
        >>.>v>...v
        >>v>>.>.v.
        v>v.vv.v..
        >.>>..v...
        .vv..>.>v.
        v.v..>>v.v
        ....v..v.>
        """,
        ex2_final: """
        ..>>v>vv..
        ..v.>>vv..
        ..>>v>>vv.
        ..>>>>>vv.
        v......>vv
        v>v....>>v
        vvv.....>>
        >vv......>
        .>v.vv.v..
        """,
        exp_ex2_blocked_step: 58,
      ]
    end

    test "parser gets expected matrix (example 1 initial)", fixture do
      assert Herd.parse(fixture.ex1_initial) == fixture.exp_ex1_initial_matrix
    end

    test "parser gets expected matrix (example 1 final)", fixture do
      assert Herd.parse(fixture.ex1_final) == fixture.exp_ex1_final_matrix
    end

    test "parser gets expected positions (example 1 initial)", fixture do
      herd = Herd.new(fixture.ex1_initial)
      assert Herd.east_pos(herd) == fixture.exp_ex1_initial_east
      assert Herd.south_pos(herd) == fixture.exp_ex1_initial_south
    end

    test "parser gets expected positions (example 1 final)", fixture do
      herd = Herd.new(fixture.ex1_final)
      assert Herd.east_pos(herd) == fixture.exp_ex1_final_east
      assert Herd.south_pos(herd) == fixture.exp_ex1_final_south
    end

    test "constructor gets correct dimensions", fixture do
      [{fixture.ex1_initial, {7, 7}}, {fixture.ex2_initial, {10, 9}}]
      |> Enum.each(fn {input, {exp_dimx, exp_dimy}} ->
        herd = Herd.new(input)
        assert herd.dimx == exp_dimx
        assert herd.dimy == exp_dimy
      end)
    end

    test "constructor exception for invalid input (uneven line widths)", fixture do
      assert_raise MatchError, fn ->
        Herd.new(fixture.uneven_widths)
      end
    end

    test "mover produces expected positions (example 1)", fixture do
      herd =
        Herd.new(fixture.ex1_initial)
        |> Herd.move(fixture.ex1_steps)
      assert Herd.east_pos(herd) == fixture.exp_ex1_final_east
      assert Herd.south_pos(herd) == fixture.exp_ex1_final_south
    end

    test "blocked-step detector gets expected step (example 2)", fixture do
      act_blocked_step =
        Herd.new(fixture.ex2_initial)
        |> Herd.blocked_step()
      assert act_blocked_step == fixture.exp_ex2_blocked_step
    end
  end
end
