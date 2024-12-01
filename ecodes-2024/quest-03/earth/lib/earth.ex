defmodule Earth do
  @moduledoc """
  Documentation for `Earth`.
  """

  import Earth.Parser
  import Kingdom.CLI
  alias Kingdom.Grid

  def dig(grid), do: dig(Grid.keys(grid), grid, :cardinals)
  def diagonal_dig(grid), do: dig(Grid.keys(grid), grid, :neighbors)

  defp dig([], grid, _rule), do: grid
  defp dig(squares, grid, rule) do
    squares = diggable_squares(squares, grid, rule)
    grid = Enum.reduce(squares, grid, &(dig_square(&1, &2)))
    dig(squares, grid, rule)
  end

  defp diggable_squares(squares, grid, rule) do
    Enum.filter(squares, fn square ->
      square_depth = Grid.get(grid, square)
      neighbors =
        case rule do
          :cardinals -> Grid.cardinals_of(grid, square)
          :neighbors -> Grid.neighbors_of(grid, square)
        end
      neighbor_depths = Enum.map(neighbors, &(Grid.get(grid, &1)))
      diggable_square?(square_depth, neighbor_depths)
    end)
  end

  defp dig_square(square, grid) do
    Grid.get_and_update(grid, square, &({&1, &1 + 1}))
  end

  def diggable_square?(0, _neighbor_depths), do: false
  def diggable_square?(depth, neighbor_depths) do
    neighbor_depths
    |> Enum.all?(&(&1 >= depth))
  end

  defp solve(1) do
    parse_input_file(1)
    |> dig()
    |> Grid.values()
    |> Enum.sum()
  end

  defp solve(2) do
    parse_input_file(2)
    |> dig()
    |> Grid.values()
    |> Enum.sum()
  end

  defp solve(3) do
    parse_input_file("private/everybody_codes_e2024_q03_p3_border.txt")
    |> diagonal_dig()
    |> Grid.values()
    |> Enum.sum()
  end

  def main(argv) do
    opts = parse_args(argv)
    opts[:parts]
    |> Enum.each(fn part ->
      solve(part)
      |> IO.inspect(label: "Part #{part}")
    end)
  end
end
