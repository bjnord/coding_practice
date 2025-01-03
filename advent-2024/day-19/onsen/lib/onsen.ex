defmodule Onsen do
  @moduledoc """
  Documentation for `Onsen`.
  """

  import Onsen.Parser
  import History.CLI

  @max_chunk 8  # biggest pattern size in `input.txt`

  def possible?(towel, patterns) do
    subpossible?(towel, patterns, patterns)
  end

  def subpossible?(_towel, nil, _all_patterns), do: false
  def subpossible?([], patterns, _all_patterns) do
    Map.get(patterns, ?.) == true
  end
  def subpossible?([color | towel], patterns, all_patterns) do
    if Map.get(patterns, ?.) == true do
      if possible?([color | towel], all_patterns) do
        true
      else
        subpossible?(towel, Map.get(patterns, color), all_patterns)
      end
    else
      subpossible?(towel, Map.get(patterns, color), all_patterns)
    end
  end

  def arrangements(towel, patterns) do
    f = &(MapSet.member?(patterns, &1))
    towel
    |> Onsen.divisions(@max_chunk, f)
    |> Enum.count()
  end

  # returns list of lists: all the ways `towel` can be divided, with the
  # given `max_chunk` size
  #
  # f is an optional filter function: should return `true` if chunk is legal,
  # `false` otherwise
  def divisions(towel, max_chunk, f \\ fn _ -> true end) do
    len = String.length(towel)
    1..min(len, max_chunk)
    |> Enum.map(&divide(towel, len, max_chunk, &1, f))
    |> Enum.reject(&(&1 == nil))
    |> Enum.reduce([], fn chunk_div, acc ->
      chunk_div
      |> Enum.reduce(acc, fn div, acc ->
        [div | acc]
      end)
    end)
  end

  # returns list of lists: all the ways `towel` can be divided, with the
  # first chunk always being the front of `towel` (size `chunk`) plus
  # all the possible divisions of the remainder
  defp divide(towel, len, _max_chunk, chunk, f) when chunk == len do
    if f.(towel) do
      [[towel]]
    else
      nil
    end
  end
  defp divide(towel, len, max_chunk, chunk, f) do
    left = String.slice(towel, 0..(chunk - 1))
    if f.(left) do
      right = String.slice(towel, chunk..(len - 1))
      divisions(right, max_chunk, f)
      |> Enum.map(fn div -> [left | div] end)
    else
      nil
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
    {towel_patterns, towels} = parse_input_file(input_path)
    towels
    |> Enum.map(&(Onsen.possible?(&1, towel_patterns)))
    |> Enum.count(&(&1))
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    {towel_patterns, towels} = parse2_input_file(input_path)
    towels
    |> Enum.map(&(Onsen.arrangements(&1, towel_patterns)))
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
