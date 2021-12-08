defmodule HydrothermalTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 100]
  doctest Hydrothermal

  describe "puzzle example" do
    setup do
      [
        vents: [
          [{0, 9}, {5, 9}],
          [{8, 0}, {0, 8}],
          [{9, 4}, {3, 4}],
          [{2, 2}, {2, 1}],
          [{7, 0}, {7, 4}],
          [{6, 4}, {2, 0}],
          [{0, 9}, {2, 9}],
          [{3, 4}, {1, 4}],
          [{0, 0}, {8, 8}],
          [{5, 5}, {8, 2}],
        ],
        exp_dimension: 10,
        exp_n_points: 39,
        exp_grid_sum: 53,
        exp_hv_overlaps: 5,
        exp_overlaps: 12,
        exp_render: """
        1.1....11.
        .111...2..
        ..2.1.111.
        ...1.2.2..
        .112313211
        ...1.2....
        ..1...1...
        .1.....1..
        1.......1.
        222111....
        """,
      ]
    end

    test "correct grid map", fixture do
      {grid, dim} = Hydrothermal.grid_map(fixture.vents)
      assert dim == fixture.exp_dimension
      assert Map.keys(grid) |> Enum.count() == fixture.exp_n_points
      assert Map.values(grid) |> Enum.sum() == fixture.exp_grid_sum
    end

    test "correct grid map rendering", fixture do
      render = Hydrothermal.grid_map(fixture.vents)
               |> Hydrothermal.render_grid_map()
      assert render == fixture.exp_render
    end

    test "correct count of horiz/vert vent overlaps", fixture do
      hv_vents = fixture.vents
                 |> Enum.filter(&Hydrothermal.horiz_or_vert?/1)
      assert Hydrothermal.vent_overlaps(hv_vents) == fixture.exp_hv_overlaps
    end

    test "correct count of all vent overlaps", fixture do
      assert Hydrothermal.vent_overlaps(fixture.vents) == fixture.exp_overlaps
    end

    test "point out of bounds tester" do
      any_out_of_bounds =
        [{0, 0}, {0, 9}, {1, 1}, {8, 8}, {9, 0}, {9, 9}]
        |> Enum.any?(fn p -> Hydrothermal.out_of_bounds?(p, 10) end)
      assert any_out_of_bounds == false
      all_out_of_bounds =
        [{-1, 0}, {0, -1}, {0, 10}, {10, 0}]
        |> Enum.all?(fn p -> Hydrothermal.out_of_bounds?(p, 10) end)
      assert all_out_of_bounds == true
    end
  end

  property "[generator] direction delta is never {0, 0}" do
    forall delta <- direction_delta() do
      delta != {0, 0}
    end
  end

  property "[generator] vents are always in bounds" do
    forall vent_list <- vent_list() do
      vents_all_in_bounds?(vent_list[:vents], vent_list[:dim])
    end
  end

  property "grid square sum matches vent point count" do
    forall vent_list <- vent_list() do
      grid_square_sum =
        vent_list[:vents]
        |> Hydrothermal.grid_map()
        |> elem(0)
        |> Map.values()
        |> Enum.sum()
      # FIXME OPTIMIZE implement a Hydrothermal.vent_length(vent)
      vent_point_count =
        vent_list[:vents]
        |> Enum.flat_map(&Hydrothermal.to_points/1)
        |> Enum.count()
      grid_square_sum == vent_point_count
    end
  end

  ###
  # Helpers
  ###

  defp vents_all_in_bounds?(vents, dim) do
    Enum.all?(vents, fn v -> vent_in_bounds?(v, dim) end)
  end

  defp vent_in_bounds?(vent, dim) do
    [start_pt, end_pt] = vent
    !Hydrothermal.out_of_bounds?(start_pt, dim) && !Hydrothermal.out_of_bounds?(end_pt, dim)
  end

  ###
  # Generators
  #
  # I find these tricky to get right, and the book and documentation are
  # somewhat lacking. Some lessons learned:
  #
  # (1) Generators return a big data object that's lazily evaluated. You
  # can only use them on the right side of an `<-` (`forall` for a list
  # and `let`/`such_that` for a scalar). If you get an arithmetic exception
  # or similar, chances are you're trying to manipulate a generator object
  # rather than the final test quantity it will produce.
  #
  # (2) PropCheck sometimes seems to trap an exception and then simply
  # report that an example failed. If you see `code: nil` that may be a
  # sign this is happening? This seems prone to happen if you make a bad
  # call (_e.g._ you got the arity wrong, or the function is private).
  # (a) Often adding IO.inspect etc. won't help; the debug output simply
  # won't appear. (b) Try setting the PROPCHECK_DETECT_EXCEPTIONS=0 env
  # var to see if that unmasks the actual exception that's happening.
  # (c) Otherwise try extracting parts of the code to helpers and/or run
  # them standalone.
  ###

  def grid_dimension() do
    sized(s, max(s, 2))
  end

  def direction() do
    # the condition excludes the dx=0,dy=0 case
    such_that d <- range(0, 8), when: d != 4
  end

  def direction_delta() do
    let dir <- direction() do
      {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 0}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}
      |> elem(dir)
    end
  end

  def grid_point(dim) do
    {range(0, dim-1), range(0, dim-1)}
  end

  def vent(dim) do
    let [{x1, y1} <- grid_point(dim), {dx, dy} <- direction_delta(), dlen <- range(1, dim-1)] do
      [{x1, y1}, {x1 + dx * dlen, y1 + dy * dlen}]
    end
  end

  def in_bounds_vent(dim) do
    such_that v <- vent(dim), when: vent_in_bounds?(v, dim)
  end

  def vent_list() do
    let dim <- grid_dimension() do
      count = div(3 * dim, 2)
      let vents <- vector(count, in_bounds_vent(dim)) do
        %{dim: dim, vents: vents}
      end
    end
  end
end
