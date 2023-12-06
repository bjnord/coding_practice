defmodule Garden do
  @moduledoc """
  Documentation for `Garden`.
  """

  import Garden.Parser
  alias Garden.Gmap
  import Snow.CLI

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
    {seeds, gmaps} = parse_input(input_file, part: 1)
    seeds
    |> Enum.map(fn seed -> Gmap.min_location(seed, gmaps) end)
    |> Enum.min()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    {seeds, gmaps} = parse_input(input_file, part: 2)
    seeds
    |> Enum.map(fn seed -> Gmap.min_location(seed, gmaps) end)
    |> Enum.min()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
