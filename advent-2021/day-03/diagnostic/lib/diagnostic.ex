defmodule Diagnostic do
  @moduledoc """
  Documentation for Diagnostic.
  """

  import Diagnostic.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1),
      do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2),
      do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts \\ []) do
    {gam, eps} = input_file
                 |> parse_input(opts)
                 |> compute_power_rates
    IO.inspect(gam * eps, label: "Part 1 answer is")
  end

  @doc """
  Compute gamma and epsilon rates from diagnostic report entries.

  Returns `{gamma, epsilon}`

  ## Example
      iex> entries = [[1, 0, 0], [1, 1, 0], [0, 0, 0]]
      iex> Diagnostic.compute_power_rates(entries)
      {0b100, 0b011}
  """
  def compute_power_rates(entries) do
    {0, 0}  # TODO
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    {o2, co2} = input_file
                |> parse_input(opts)
                |> compute_life_support_ratings
    IO.inspect(o2 * co2, label: "Part 2 answer is")
  end

  @doc """
  Compute O₂ and CO₂ ratings from diagnostic report entries.

  Returns `{o2, co2}`

  ## Examples
      iex> entries = [[1, 0, 0], [1, 1, 0], [0, 1, 0]]
      iex> Diagnostic.compute_life_support_ratings(entries)
      {0b110, 0b010}
  """
  def compute_life_support_ratings(entries) do
    {0, 0}  # TODO
  end

  @doc """
  Transpose a two-dimensional array.

  h/t [this StackOverflow answer](https://stackoverflow.com/a/23706084/291754)

  ## Examples
      iex> Diagnostic.transpose([[1, 2], [3, 4], [5, 6]])
      [[1, 3, 5], [2, 4, 6]]
  """
  def transpose([[] | _]), do: []
  def transpose(a) do
      [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end
end
