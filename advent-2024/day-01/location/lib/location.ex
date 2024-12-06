defmodule Location do
  @moduledoc """
  Documentation for `Location`.
  """

  import History.CLI
  import Location.Parser

  def location_pair_diff({alist, blist}) do
    [Enum.sort(alist), Enum.sort(blist)]
    |> Enum.zip()
    |> Enum.map(fn {a, b} -> abs(a - b) end)
  end

  def similarity({alist, blist}) do
    bcount = occurrence_count(blist)
    Enum.map(alist, &(&1 * Map.get(bcount, &1, 0)))
  end

  defp occurrence_count(llist) do
    Enum.reduce(llist, %{}, fn n, acc ->
      Map.update(acc, n, 1, &(&1 + 1))
    end)
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
    |> location_pair_diff()
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> similarity()
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
