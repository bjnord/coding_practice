defmodule Cafe do
  @moduledoc """
  Documentation for `Cafe`.
  """

  import Cafe.Parser
  import Decor.CLI

  @type ingredient() :: pos_integer()
  @type fresh_range() :: {ingredient(), ingredient()}
  @type inventory() :: {[fresh_range()], [ingredient()]}

  @doc """
  Find fresh ingredients in an inventory.
  """
  @spec find_fresh_ingredients(inventory()) :: [ingredient()]
  def find_fresh_ingredients({fresh_ranges, ingredients}) do
    ingredients
    |> Enum.filter(fn ing ->
      fresh_ranges
      |> Enum.any?(fn range -> in_range?(range, ing) end)
    end)
  end

  @spec in_range?(fresh_range(), ingredient()) :: boolean()
  defp in_range?({lo, hi}, n) do
    (lo <= n) && (n <= hi)
  end

  @doc """
  Combine overlapping ranges in an inventory.
  """
  @spec combine_ranges(inventory()) :: [ingredient()]
  def combine_ranges({fresh_ranges, _ingredients}) do
    fresh_ranges
    |> Enum.sort()
    |> combine_next_range([])
  end

  defp combine_next_range([], acc), do: acc

  defp combine_next_range([next_range | ranges], []) do
    combine_next_range(ranges, [next_range])
  end

  defp combine_next_range([{next_lo, next_hi} | ranges], [{prev_lo, prev_hi} | acc]) do
    if prev_hi < next_lo do
      combine_next_range(ranges, [{next_lo, next_hi}, {prev_lo, prev_hi} | acc])
    else
      combine_next_range(ranges, [{min(prev_lo, next_lo), max(prev_hi, next_hi)} | acc])
    end
  end

  @doc """
  Count ingredients in a list of ranges.
  """
  @spec count_ingredients([fresh_range()]) :: pos_integer()
  def count_ingredients(ranges) do
    ranges
    |> Enum.map(fn {lo, hi} -> hi - lo + 1 end)
    |> Enum.sum()
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
    |> find_fresh_ingredients()
    |> Enum.count()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Cafe.combine_ranges()
    |> Cafe.count_ingredients()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
