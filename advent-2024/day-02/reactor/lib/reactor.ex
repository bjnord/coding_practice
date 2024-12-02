defmodule Reactor do
  @moduledoc """
  Documentation for `Reactor`.
  """

  import Reactor.Parser
  import Snow.CLI

  def analyze_safety(levels) do
    steps = analyze_steps(levels)
    cond do
      Enum.all?(steps, &(&1 == :safe_rise)) ->
        :safe
      Enum.all?(steps, &(&1 == :safe_fall)) ->
        :safe
      true ->
        :unsafe
    end
  end

  def analyze_safety_with_dampener(levels) do
    if analyze_safety(levels) == :safe do
      :safe
    else
      analyze_safety_after_removal(levels, 0, length(levels))
    end
  end

  defp analyze_safety_after_removal(_levels, i, count) when i == count, do: :unsafe
  defp analyze_safety_after_removal(levels, i, count) do
    if analyze_safety(List.delete_at(levels, i)) == :safe do
      :safe
    else
      analyze_safety_after_removal(levels, i + 1, count)
    end
  end

  def analyze_steps(levels) do
    levels
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&analyze_pair/1)
  end

  defp analyze_pair([a, b]) do
    cond do
      (b > a) && ((b - a) <= 3) ->
        :safe_rise
      (b > a) ->
        :unsafe_rise
      (a > b) && ((a - b) <= 3) ->
        :safe_fall
      (a > b) ->
        :unsafe_fall
      a == b ->
        :static
    end
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
    |> Enum.map(&Reactor.analyze_safety/1)
    |> Enum.count(&(&1 == :safe))
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    |> Enum.map(&Reactor.analyze_safety_with_dampener/1)
    |> Enum.count(&(&1 == :safe))
    |> IO.inspect(label: "Part 2 answer is")
  end
end
