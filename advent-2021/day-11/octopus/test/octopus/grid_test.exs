defmodule Octopus.GridTest do
  use ExUnit.Case
  doctest Octopus.Grid

  describe "puzzle example" do
    setup do
      [
        input5: """
        11111
        19991
        19191
        19991
        11111
        """,
        matrix5: [
          {
            {1, 1, 1, 1, 1},
            {1, 9, 9, 9, 1},
            {1, 9, 1, 9, 1},
            {1, 9, 9, 9, 1},
            {1, 1, 1, 1, 1},
          },
          {
            {3, 4, 5, 4, 3},
            {4, 0, 0, 0, 4},
            {5, 0, 0, 0, 5},
            {4, 0, 0, 0, 4},
            {3, 4, 5, 4, 3},
          },
          {
            {4, 5, 6, 5, 4},
            {5, 1, 1, 1, 5},
            {6, 1, 1, 1, 6},
            {5, 1, 1, 1, 5},
            {4, 5, 6, 5, 4},
          },
        ],
        exp_matrix5_flashes: 9,
        input10: """
        5483143223
        2745854711
        5264556173
        6141336146
        6357385478
        4167524645
        2176841721
        6882881134
        4846848554
        5283751526
        """,
        matrix10: [
          {
            {5, 4, 8, 3, 1, 4, 3, 2, 2, 3},
            {2, 7, 4, 5, 8, 5, 4, 7, 1, 1},
            {5, 2, 6, 4, 5, 5, 6, 1, 7, 3},
            {6, 1, 4, 1, 3, 3, 6, 1, 4, 6},
            {6, 3, 5, 7, 3, 8, 5, 4, 7, 8},
            {4, 1, 6, 7, 5, 2, 4, 6, 4, 5},
            {2, 1, 7, 6, 8, 4, 1, 7, 2, 1},
            {6, 8, 8, 2, 8, 8, 1, 1, 3, 4},
            {4, 8, 4, 6, 8, 4, 8, 5, 5, 4},
            {5, 2, 8, 3, 7, 5, 1, 5, 2, 6},
          },
          {
            {6, 5, 9, 4, 2, 5, 4, 3, 3, 4},
            {3, 8, 5, 6, 9, 6, 5, 8, 2, 2},
            {6, 3, 7, 5, 6, 6, 7, 2, 8, 4},
            {7, 2, 5, 2, 4, 4, 7, 2, 5, 7},
            {7, 4, 6, 8, 4, 9, 6, 5, 8, 9},
            {5, 2, 7, 8, 6, 3, 5, 7, 5, 6},
            {3, 2, 8, 7, 9, 5, 2, 8, 3, 2},
            {7, 9, 9, 3, 9, 9, 2, 2, 4, 5},
            {5, 9, 5, 7, 9, 5, 9, 6, 6, 5},
            {6, 3, 9, 4, 8, 6, 2, 6, 3, 7},
          },
          {
            {8, 8, 0, 7, 4, 7, 6, 5, 5, 5},
            {5, 0, 8, 9, 0, 8, 7, 0, 5, 4},
            {8, 5, 9, 7, 8, 8, 9, 6, 0, 8},
            {8, 4, 8, 5, 7, 6, 9, 6, 0, 0},
            {8, 7, 0, 0, 9, 0, 8, 8, 0, 0},
            {6, 6, 0, 0, 0, 8, 8, 9, 8, 9},
            {6, 8, 0, 0, 0, 0, 5, 9, 4, 3},
            {0, 0, 0, 0, 0, 0, 7, 4, 5, 6},
            {9, 0, 0, 0, 0, 0, 0, 8, 7, 6},
            {8, 7, 0, 0, 0, 0, 6, 8, 4, 8},
          },
          {
            {0, 0, 5, 0, 9, 0, 0, 8, 6, 6},
            {8, 5, 0, 0, 8, 0, 0, 5, 7, 5},
            {9, 9, 0, 0, 0, 0, 0, 0, 3, 9},
            {9, 7, 0, 0, 0, 0, 0, 0, 4, 1},
            {9, 9, 3, 5, 0, 8, 0, 0, 6, 3},
            {7, 7, 1, 2, 3, 0, 0, 0, 0, 0},
            {7, 9, 1, 1, 2, 5, 0, 0, 0, 9},
            {2, 2, 1, 1, 1, 3, 0, 0, 0, 0},
            {0, 4, 2, 1, 1, 2, 5, 0, 0, 0},
            {0, 0, 2, 1, 1, 1, 9, 0, 0, 0},
          },
          {
            {2, 2, 6, 3, 0, 3, 1, 9, 7, 7},
            {0, 9, 2, 3, 0, 3, 1, 6, 9, 7},
            {0, 0, 3, 2, 2, 2, 1, 1, 5, 0},
            {0, 0, 4, 1, 1, 1, 1, 1, 6, 3},
            {0, 0, 7, 6, 1, 9, 1, 1, 7, 4},
            {0, 0, 5, 3, 4, 1, 1, 1, 2, 2},
            {0, 0, 4, 2, 3, 6, 1, 1, 2, 0},
            {5, 5, 3, 2, 2, 4, 1, 1, 2, 2},
            {1, 5, 3, 2, 2, 4, 7, 2, 1, 1},
            {1, 1, 3, 2, 2, 3, 0, 2, 1, 1},
          },
          {
            {4, 4, 8, 4, 1, 4, 4, 0, 0, 0},
            {2, 0, 4, 4, 1, 4, 4, 0, 0, 0},
            {2, 2, 5, 3, 3, 3, 3, 4, 9, 3},
            {1, 1, 5, 2, 3, 3, 3, 2, 7, 4},
            {1, 1, 8, 7, 3, 0, 3, 2, 8, 5},
            {1, 1, 6, 4, 6, 3, 3, 2, 3, 3},
            {1, 1, 5, 3, 4, 7, 2, 2, 3, 1},
            {6, 6, 4, 3, 3, 5, 2, 2, 3, 3},
            {2, 6, 4, 3, 3, 5, 8, 3, 2, 2},
            {2, 2, 4, 3, 3, 4, 1, 3, 2, 2},
          },
          {
            {5, 5, 9, 5, 2, 5, 5, 1, 1, 1},
            {3, 1, 5, 5, 2, 5, 5, 2, 2, 2},
            {3, 3, 6, 4, 4, 4, 4, 6, 0, 5},
            {2, 2, 6, 3, 4, 4, 4, 4, 9, 6},
            {2, 2, 9, 8, 4, 1, 4, 3, 9, 6},
            {2, 2, 7, 5, 7, 4, 4, 3, 4, 4},
            {2, 2, 6, 4, 5, 8, 3, 3, 4, 2},
            {7, 7, 5, 4, 4, 6, 3, 3, 4, 4},
            {3, 7, 5, 4, 4, 6, 9, 4, 3, 3},
            {3, 3, 5, 4, 4, 5, 2, 4, 3, 3},
          },
          {
            {6, 7, 0, 7, 3, 6, 6, 2, 2, 2},
            {4, 3, 7, 7, 3, 6, 6, 3, 3, 3},
            {4, 4, 7, 5, 5, 5, 5, 8, 2, 7},
            {3, 4, 9, 6, 6, 5, 5, 7, 0, 9},
            {3, 5, 0, 0, 6, 2, 5, 6, 0, 9},
            {3, 5, 0, 9, 9, 5, 5, 5, 6, 6},
            {3, 4, 8, 6, 6, 9, 4, 4, 5, 3},
            {8, 8, 6, 5, 5, 8, 5, 5, 5, 5},
            {4, 8, 6, 5, 5, 8, 0, 6, 4, 4},
            {4, 4, 6, 5, 5, 7, 4, 6, 4, 4},
          },
          {
            {7, 8, 1, 8, 4, 7, 7, 3, 3, 3},
            {5, 4, 8, 8, 4, 7, 7, 4, 4, 4},
            {5, 6, 9, 7, 6, 6, 6, 9, 4, 9},
            {4, 6, 0, 8, 7, 6, 6, 8, 3, 0},
            {4, 7, 3, 4, 9, 4, 6, 7, 3, 0},
            {4, 7, 4, 0, 0, 9, 7, 6, 8, 8},
            {6, 9, 0, 0, 0, 0, 7, 5, 6, 4},
            {0, 0, 0, 0, 0, 0, 9, 6, 6, 6},
            {8, 0, 0, 0, 0, 0, 4, 7, 5, 5},
            {6, 8, 0, 0, 0, 0, 7, 7, 5, 5},
          },
          {
            {9, 0, 6, 0, 0, 0, 0, 6, 4, 4},
            {7, 8, 0, 0, 0, 0, 0, 9, 7, 6},
            {6, 9, 0, 0, 0, 0, 0, 0, 8, 0},
            {5, 8, 4, 0, 0, 0, 0, 0, 8, 2},
            {5, 8, 5, 8, 0, 0, 0, 0, 9, 3},
            {6, 9, 6, 2, 4, 0, 0, 0, 0, 0},
            {8, 0, 2, 1, 2, 5, 0, 0, 0, 9},
            {2, 2, 2, 1, 1, 3, 0, 0, 0, 9},
            {9, 1, 1, 1, 1, 2, 8, 0, 9, 7},
            {7, 9, 1, 1, 1, 1, 9, 9, 7, 6},
          },
          {
            {0, 4, 8, 1, 1, 1, 2, 9, 7, 6},
            {0, 0, 3, 1, 1, 1, 2, 0, 0, 9},
            {0, 0, 4, 1, 1, 1, 2, 5, 0, 4},
            {0, 0, 8, 1, 1, 1, 1, 4, 0, 6},
            {0, 0, 9, 9, 1, 1, 1, 3, 0, 6},
            {0, 0, 9, 3, 5, 1, 1, 2, 3, 3},
            {0, 4, 4, 2, 3, 6, 1, 1, 3, 0},
            {5, 5, 3, 2, 2, 5, 2, 3, 5, 0},
            {0, 5, 3, 2, 2, 5, 0, 6, 0, 0},
            {0, 0, 3, 2, 2, 4, 0, 0, 0, 0},
          },
        ],
        exp_matrix10_flashes: 204,
        exp_matrix10_flashes_100_steps: 1656,
        exp_matrix10_synchronized_step: 195,
        nonsquare: """
        54831432
        27458547
        52645561
        61413361
        63573854
        """,
        uneven_widths: """
        548314
        274585
        52645
        614133
        """,
      ]
    end

    test "parser gets expected entries", fixture do
      act_matrix = Octopus.Grid.parse(fixture.input10)
      assert act_matrix == Enum.at(fixture.matrix10, 0)
    end

    test "constructor gets correct dimensions", fixture do
      [{fixture.input5, {5, 5}}, {fixture.input10, {10, 10}}, {fixture.nonsquare, {8, 5}}]
      |> Enum.each(fn {input, {exp_dimx, exp_dimy}} ->
        grid = Octopus.Grid.new(input)
        assert grid.dimx == exp_dimx
        assert grid.dimy == exp_dimy
      end)
    end

    test "constructor exception for invalid input (uneven line widths)", fixture do
      assert_raise MatchError, fn ->
        Octopus.Grid.new(fixture.uneven_widths)
      end
    end

    test "stepper counts flashes correctly", fixture do
      [
        {fixture.input5, fixture.matrix5, fixture.exp_matrix5_flashes},
        {fixture.input10, fixture.matrix10, fixture.exp_matrix10_flashes},
      ]
      |> Enum.each(fn {input, [_step0 | steps], exp_total_flashes} ->
        grid =
          steps
          |> Enum.reduce(Octopus.Grid.new(input), fn (step, grid) ->
            exp_flashes = count_zeros(step)
            flashes0 = grid.flashes
            grid = Octopus.Grid.increase_energy(grid)
            assert grid.flashes - flashes0 == exp_flashes
            grid
          end)
        assert grid.flashes == exp_total_flashes
      end)
    end

    test "stepper creates new grid matrix correctly", fixture do
      [
        {fixture.input5, fixture.matrix5},
        {fixture.input10, fixture.matrix10},
      ]
      |> Enum.each(fn {input, [_step0 | steps]} ->
        steps
        |> Enum.reduce(Octopus.Grid.new(input), fn (step, grid) ->
          grid = Octopus.Grid.increase_energy(grid)
          assert grid.grid == step
          grid
        end)
      end)
    end

    test "stepper counts flashes correctly for 100 steps", fixture do
      grid =
        1..100
        |> Enum.reduce(Octopus.Grid.new(fixture.input10), fn (_n, grid) ->
          Octopus.Grid.increase_energy(grid)
        end)
      assert grid.flashes == fixture.exp_matrix10_flashes_100_steps
    end

    test "stepper produces synchronicity correctly", fixture do
      n_steps =
        1..1_000_000
        |> Enum.reduce_while(Octopus.Grid.new(fixture.input10), fn (n, grid) ->
          grid = Octopus.Grid.increase_energy(grid)
          if Octopus.Grid.synchronized?(grid) do
            {:halt, n}
          else
            {:cont, grid}
          end
        end)
      assert n_steps == fixture.exp_matrix10_synchronized_step
    end
  end

  def count_zeros(input) do
    input
    |> Tuple.to_list()
    |> Enum.reduce(0, fn (row, count) ->
      zeros =
        row
        |> Tuple.to_list()
        |> Enum.count(fn col -> col == 0 end)
      count + zeros
    end)
  end
end
