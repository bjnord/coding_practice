defmodule Lanternfish do
  @moduledoc """
  Documentation for `Lanternfish`.
  """

  import Lanternfish.Parser
  import History.CLI
  alias History.Grid

  def movements(grid, _directions) do
    [{grid, grid.meta.start}]
  end

  def dump_string({grid, {ry, rx}}) do
    0..(grid.size.y - 1)
    |> Enum.map(&(dump_line(grid, &1, {ry, rx})))
    |> Enum.join("\n")
    |> then(fn s -> s <> "\n" end)
  end

  defp dump_line(grid, y, {ry, rx}) do
    0..(grid.size.x - 1)
    |> Enum.map(&(dump_char(grid, {y, &1}, {ry, rx})))
    |> List.to_string()
  end

  defp dump_char(grid, {y, x}, {ry, rx}) do
    ch = Grid.get(grid, {y, x})
    cond do
      (y == ry) && (x == rx) -> ?@
      ch == ?# -> ?#
      ch == ?O -> ?O
      true     -> ?.
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
