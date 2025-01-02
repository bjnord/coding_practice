defmodule Xmas do
  @moduledoc """
  Documentation for `Xmas`.
  """

  import History.CLI
  alias History.Grid
  import Xmas.Parser

  @spec count_xmas(Grid.t()) :: non_neg_integer()
  def count_xmas(grid) do
    deltas = [
      {0, 1},   # horizontal
      {0, -1},  # horizontal backwards
      {1, 0},   # vertical
      {-1, 0},  # vertical backwards
      {1, 1},   # diagonal right
      {-1, -1}, # diagonal right backwards
      {1, -1},  # diagonal left
      {-1, 1},  # diagonal left backwards
    ]
    for y <- 0..(grid.size.y - 1),
        x <- 0..(grid.size.x - 1),
        delta <- deltas do
      word_at(grid, {y, x}, delta)
    end
    |> Enum.count(&(&1 == ~c"XMAS"))
  end

  defp word_at(grid, {y0, x0}, {dy, dx}) do
    0..3
    |> Enum.map(fn d -> {y0 + dy * d, x0 + dx * d} end)
    |> Enum.map(&(Grid.get(grid, &1)))
  end

  @spec count_xmas(Grid.t()) :: non_neg_integer()
  def count_x_mas(grid) do
    Grid.keys(grid)
    |> Enum.reduce(0, fn pos, acc ->
      case Grid.get(grid, pos) do
        ?A -> acc + count_mas(grid, pos)
        _  -> acc
      end
    end)
  end

  defp count_mas(grid, pos) do
    if matches_mas?(grid, pos) do
      1
    else
      0
    end
  end

  defp matches_mas?(grid, {y, x}) do
    mas?(Grid.get(grid, {y - 1, x - 1}), Grid.get(grid, {y + 1, x + 1})) &&
    mas?(Grid.get(grid, {y - 1, x + 1}), Grid.get(grid, {y + 1, x - 1}))
  end

  defp mas?(?M, ?S), do: true
  defp mas?(?S, ?M), do: true
  defp mas?(_, _), do: false

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> count_xmas()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> count_x_mas()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
