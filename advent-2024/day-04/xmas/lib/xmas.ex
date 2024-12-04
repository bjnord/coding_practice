defmodule Xmas do
  @moduledoc """
  Documentation for `Xmas`.
  """

  alias Xmas.Grid
  import Xmas.Parser
  import Snow.CLI

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
    #|> IO.inspect(label: "words")
    |> Enum.count(&(&1 == ~c"XMAS"))
  end

  defp xmas_at(grid, {y0, x0}, {dy, dx}) do
    0..3
    |> Enum.map(fn d -> {y0 + dy * d, x0 + dx * d} end)
    |> Enum.map(&(Grid.get(grid, &1)))
    #|> IO.inspect(label: "pos #{y0},#{x0} delta #{dy},#{dx}")
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
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
