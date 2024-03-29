defmodule Whale do
  @moduledoc """
  Documentation for Whale.
  """

  import Whale.Parser
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2), do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> find_cheapest_fuel()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Find cheapest fuel cost to align `crabs` to the same position (simple calculation).
  """
  def find_cheapest_fuel(crabs) do
    min = Enum.min(crabs)
    max = Enum.max(crabs)
    min..max
    |> Enum.map(fn p -> align_crabs_fuel(p, crabs) end)
    |> Enum.min()
  end

  @doc """
  Determine fuel cost to align `crabs` to `pos` (simple calculation).
  """
  def align_crabs_fuel(pos, crabs) do
    crabs
    |> Enum.reduce(0, fn (cpos, fuel) -> fuel + abs(cpos - pos) end)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> find_cheapest_fuel_c()
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Find cheapest fuel cost to align `crabs` to the same position (complex calculation).
  """
  def find_cheapest_fuel_c(crabs) do
    min = Enum.min(crabs)
    max = Enum.max(crabs)
    min..max
    |> Enum.map(fn p -> align_crabs_fuel_c(p, crabs) end)
    |> Enum.min()
  end

  @doc """
  Determine fuel cost to align `crabs` to `pos` (complex calculation).
  """
  def align_crabs_fuel_c(pos, crabs) do
    crabs
    |> Enum.reduce(0, fn (cpos, fuel) -> fuel + complex_cost(cpos, pos) end)
  end
  defp complex_cost(cpos, pos) do
    dist = abs(cpos - pos)
    div(dist * (dist + 1), 2)  # triangular number
  end
end
