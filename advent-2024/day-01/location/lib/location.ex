defmodule Location do
  @moduledoc """
  Documentation for `Location`.
  """

  import Location.Parser
  import Snow.CLI

  def sort_columns(pairs) do
    pairs
    |> Enum.unzip()
    |> then(fn {alist, blist} ->
      {
        Enum.sort(alist),
        Enum.sort(blist),
      }
    end)
    |> then(fn {alist, blist} -> Enum.zip(alist, blist) end)
  end

  def pair_diff(pairs) do
    pairs
    |> Enum.map(fn {a, b} -> abs(a - b) end)
  end

  def similarity(pairs) do
    {alist, blist} =
      pairs
      |> Enum.unzip()
    bcount =
      Enum.reduce(blist, %{}, fn n, acc ->
        Map.update(acc, n, 1, &(&1 + 1))
      end)
    alist
    |> Enum.map(&(&1 * Map.get(bcount, &1, 0)))
  end

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    parse_input(input_file)
    |> sort_columns()
    |> pair_diff()
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    |> similarity()
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
