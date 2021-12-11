defmodule Octopus.GridTest do
  use ExUnit.Case
  doctest Octopus.Grid

  describe "puzzle example" do
    setup do
      [
        input5: [
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
        input10: [
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
        ],
      ]
    end

    test "constructor gets correct dimension", fixture do
      [{List.first(fixture.input5), 5}, {List.first(fixture.input10), 10}]
      |> Enum.each(fn {input, exp_dim} ->
        grid = Octopus.Grid.new(input)
        assert grid.dim == exp_dim
      end)
    end
  end
end
