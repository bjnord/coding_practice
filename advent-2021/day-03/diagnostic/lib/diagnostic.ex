defmodule Diagnostic do
  @moduledoc """
  Documentation for Diagnostic.
  """

  import Diagnostic.Parser
  import Submarine
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
    {γ, ε} = input_file
             |> parse_input(opts)
             |> compute_power_rates
    IO.inspect(γ * ε, label: "Part 1 answer is")
  end

  @doc """
  Compute γ and ε rates from diagnostic report entries.

  ## Examples
      iex> entries = [[1, 0, 0], [1, 1, 0], [0, 0, 0]]
      iex> Diagnostic.compute_power_rates(entries)
      {0b100, 0b011}
  """
  def compute_power_rates(entries) do
    x_entries = transpose(entries)
    {
      power_rate(x_entries, &Diagnostic.most_common/1),
      power_rate(x_entries, &Diagnostic.least_common/1),
    }
  end

  @doc """
  Compute γ or ε rate from transposed diagnostic report entries.
  """
  def power_rate(x_entries, common_func) do
    x_entries
    |> Enum.map(&Diagnostic.count_bits/1)
    |> Enum.map(common_func)
    |> bits_to_integer
  end
  def count_bits(bits) do
    bits
    |> Enum.reduce(0, fn (b, acc) -> acc + plus_minus(b) end)
  end
  def plus_minus(bit) when bit == 0, do: -1
  def plus_minus(_bit), do: 1
  def most_common(sum) when sum < 0, do: 0
  def most_common(_sum), do: 1
  def least_common(sum) when sum < 0, do: 1
  def least_common(_sum), do: 0

  @doc """
  Render bit list as an integer.

  ## Examples
      iex> Diagnostic.bits_to_integer([0, 1])
      1
      iex> Diagnostic.bits_to_integer([1, 0])
      2
      iex> Diagnostic.bits_to_integer([1, 1, 0, 1, 0, 0, 0, 1])
      209
  """
  def bits_to_integer(bits) do
    bits
    |> Enum.reduce(0, fn (b, acc) -> acc * 2 + b end)
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

  ## Examples
      iex> entries = [[1, 0, 0], [1, 1, 0], [0, 1, 0]]
      iex> Diagnostic.compute_life_support_ratings(entries)
      {0b110, 0b010}
  """
  def compute_life_support_ratings(entries) do
    {
      life_support_rating(entries, &Diagnostic.most_common/1),
      life_support_rating(entries, &Diagnostic.least_common/1),
    }
  end

  @doc """
  Compute O₂ or CO₂ rating from diagnostic report entries.
  """
  def life_support_rating(entries, common_func), do: life_support_rating(entries, 0, common_func)
  def life_support_rating([entry], _, _), do: bits_to_integer(entry)
  def life_support_rating(entries, pos, common_func) do
    # keep entries whose `pos`th bit has the most common value
    filter_bit = transpose(entries)
                 |> Enum.map(&Diagnostic.count_bits/1)
                 |> Enum.map(common_func)
                 |> Enum.at(pos)
    filtered_entries = entries
                       |> Enum.filter(fn entry -> Enum.at(entry, pos) == filter_bit end)
    # continue to next `pos` (using tail recursion)
    life_support_rating(filtered_entries, pos + 1, common_func)
  end
end
