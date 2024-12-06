defmodule Xmas do
  @moduledoc """
  Documentation for `Xmas`.
  """

  import History.CLI
  alias Xmas.Grid
  import Xmas.Parser

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
      xmas_at(grid, {y, x}, delta)
    end
    |> Enum.count(&(&1 == ~c"XMAS"))
  end

  defp xmas_at(grid, {y0, x0}, {dy, dx}) do
    0..3
    |> Enum.map(fn d -> {y0 + dy * d, x0 + dx * d} end)
    |> Enum.map(&(Grid.get(grid, &1)))
  end

  def count_x_mas(grid) do
    Grid.keys(grid)
    |> Enum.reduce(0, fn pos, acc ->
      case Grid.get(grid, pos) do
        ?M -> acc + count_m(grid, pos)
        _  -> acc
      end
    end)
  end

  defp count_m(grid, pos) do
    count_m_right(grid, pos) + count_m_down(grid, pos)
  end

  def count_m_right(grid, {y, x}) do
    if Grid.get(grid, {y, x + 2}) == ?M do
      count_a_down(grid, {y, x}) + count_a_up(grid, {y, x})
    else
      0
    end
  end

  def count_a_down(grid, {y, x}) do
    if Grid.get(grid, {y + 1, x + 1}) == ?A do
      count_s_down(grid, {y, x})
    else
      0
    end
  end

  defp count_s_down(grid, {y, x}) do
    if (Grid.get(grid, {y + 2, x}) == ?S) && (Grid.get(grid, {y + 2, x + 2}) == ?S) do
      1
    else
      0
    end
  end

  def count_a_up(grid, {y, x}) do
    if Grid.get(grid, {y - 1, x + 1}) == ?A do
      count_s_up(grid, {y, x})
    else
      0
    end
  end

  defp count_s_up(grid, {y, x}) do
    if (Grid.get(grid, {y - 2, x}) == ?S) && (Grid.get(grid, {y - 2, x + 2}) == ?S) do
      1
    else
      0
    end
  end

  def count_m_down(grid, {y, x}) do
    if Grid.get(grid, {y + 2, x}) == ?M do
      count_a_right(grid, {y, x}) + count_a_left(grid, {y, x})
    else
      0
    end
  end

  def count_a_right(grid, {y, x}) do
    if Grid.get(grid, {y + 1, x + 1}) == ?A do
      count_s_right(grid, {y, x})
    else
      0
    end
  end

  defp count_s_right(grid, {y, x}) do
    if (Grid.get(grid, {y, x + 2}) == ?S) && (Grid.get(grid, {y + 2, x + 2}) == ?S) do
      1
    else
      0
    end
  end

  def count_a_left(grid, {y, x}) do
    if Grid.get(grid, {y + 1, x - 1}) == ?A do
      count_s_left(grid, {y, x})
    else
      0
    end
  end

  defp count_s_left(grid, {y, x}) do
    if (Grid.get(grid, {y, x - 2}) == ?S) && (Grid.get(grid, {y + 2, x - 2}) == ?S) do
      1
    else
      0
    end
  end

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
