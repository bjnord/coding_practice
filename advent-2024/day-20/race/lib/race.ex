defmodule Race do
  @moduledoc """
  Documentation for `Race`.
  """

  import Race.Parser
  import History.CLI
  alias History.Grid

  def cheats(grid) do
    for y <- 0..(grid.size.y - 1),
      x <- 0..(grid.size.x - 1) do
        cheats(grid, {y, x}, Grid.get(grid, {y, x}))
      end
      |> List.flatten()
      |> Enum.sort()
  end

  defp cheats(_grid, _pos, ?#), do: []
  defp cheats(grid, {y, x}, nil) do
    Grid.cardinals_of(grid, {y, x})
    |> Enum.map(&(cheat(grid, {y, x}, &1)))
    |> Enum.reject(&(&1 == nil))
  end

  defp cheat(grid, {y, x}, {ny, nx}) do
    {dy, dx} = {ny - y, nx - x}
    {nny, nnx} = {ny + dy, nx + dx}
    cond do
      Grid.get(grid, {ny, nx}) != ?#     -> nil
      !Grid.in_bounds?(grid, {nny, nnx}) -> nil
      Grid.get(grid, {nny, nnx}) == ?#   -> nil
      true                               -> {{ny, nx}, {nny, nnx}}
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
    nil  # TODO
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
