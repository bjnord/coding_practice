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

  ## Examples
      iex> entries = [[1, 0, 0], [1, 1, 0], [0, 0, 0]]
      iex> Diagnostic.compute_power_rates(entries)
      {0b100, 0b011}
  """
  def compute_power_rates(entries) do
    x_entries = transpose(entries)
    {gamma_rate(x_entries), epsilon_rate(x_entries)}
  end

  @doc """
  Compute gamma rate from transposed diagnostic report entries.
  """
  def gamma_rate(x_entries) do
    x_entries
    |> Enum.map(&Diagnostic.count_bits/1)
    |> Enum.map(&Diagnostic.most_common/1)
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
  Compute epsilon rate from transposed diagnostic report entries.
  """
  def epsilon_rate(x_entries) do
    x_entries
    |> Enum.map(&Diagnostic.count_bits/1)
    |> Enum.map(&Diagnostic.least_common/1)
    |> bits_to_integer
  end
  def least_common(sum) when sum < 0, do: 1
  def least_common(_sum), do: 0

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
    {o2_rating(entries), co2_rating(entries)}
  end

  @doc """
  Compute O₂ rating from diagnostic report entries.
  """
  def o2_rating(entries), do: o2_rating(entries, 0)
  def o2_rating([entry], _), do: bits_to_integer(entry)
  def o2_rating(entries, pos) do
    # keep entries whose `pos`th bit has the most common value
    filter_bit = transpose(entries)
                 |> Enum.map(&Diagnostic.count_bits/1)
                 |> Enum.map(&Diagnostic.most_common/1)
                 |> Enum.at(pos)
    filtered_entries = entries
                       |> Enum.filter(fn entry -> Enum.at(entry, pos) == filter_bit end)
    # continue to next `pos` (using tail recursion)
    o2_rating(filtered_entries, pos + 1)
  end

  @doc """
  Compute CO₂ rating from diagnostic report entries.
  """
  def co2_rating(entries), do: co2_rating(entries, 0)
  def co2_rating([entry], _), do: bits_to_integer(entry)
  def co2_rating(entries, pos) do
    # keep entries whose `pos`th bit has the least common value
    filter_bit = transpose(entries)
                 |> Enum.map(&Diagnostic.count_bits/1)
                 |> Enum.map(&Diagnostic.least_common/1)
                 |> Enum.at(pos)
    filtered_entries = entries
                       |> Enum.filter(fn entry -> Enum.at(entry, pos) == filter_bit end)
    # continue to next `pos` (using tail recursion)
    co2_rating(filtered_entries, pos + 1)
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
