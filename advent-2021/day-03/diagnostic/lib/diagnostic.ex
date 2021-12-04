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
    # convert entries to tuple buckets and sum them
    entry_sum = entries
                |> Stream.map(&Diagnostic.bucketize_bits/1)
                |> Diagnostic.sum_bucket_entries()
    # calculate gamma and epsilon rates from sum
    gamma = gamma_rate(entry_sum)
    epsilon = epsilon_rate(entry_sum)
    {gamma, epsilon}
  end

  @doc """
  Sum tuple bucket entries.

  ## Examples
      iex(1)> bucket_entries = [
      ...(1)>   [{1, 0}, {1, 0}, {1, 0}, {0, 1}, {1, 0}],
      ...(1)>   [{0, 1}, {0, 1}, {0, 1}, {0, 1}, {1, 0}],
      ...(1)> ]
      iex> Diagnostic.sum_bucket_entries(bucket_entries)
      [{1, 1}, {1, 1}, {1, 1}, {0, 2}, {2, 0}]
  """
  def sum_bucket_entries(bucket_entries) do
    # do a look-ahead to find bit length of first entry
    [len | _tail] = bucket_entries
                    |> Stream.take(1)
                    |> Enum.map(fn x -> Enum.count(x) end)
    # construct an accumulator of the right length
    acc = bucket_acc(len)
    # sum the entries
    bucket_entries
    |> Enum.reduce(acc, &Diagnostic.add_bucket_entries/2)
  end

  @doc """
  Transform bits to tuple buckets.

  ## Examples
      iex> Diagnostic.bucketize_bits([0, 0, 0, 1, 0])
      [{1, 0}, {1, 0}, {1, 0}, {0, 1}, {1, 0}]
      iex> Diagnostic.bucketize_bits([1, 1, 1, 1, 0])
      [{0, 1}, {0, 1}, {0, 1}, {0, 1}, {1, 0}]
  """
  def bucketize_bits(bits) do
    bits
    |> Enum.map(&Diagnostic.bit_to_tuple/1)
  end
  def bit_to_tuple(bit) when bit == 0, do: {1, 0}
  def bit_to_tuple(bit) when bit == 1, do: {0, 1}

  @doc """
  Generate tuple bucket accumulator of length `len`.

  ## Examples
      iex> Diagnostic.bucket_acc(5)
      [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
  """
  def bucket_acc(len) do
    List.duplicate({0, 0}, len)
  end

  @doc """
  Add two tuple bucket entries.

  ## Examples
      iex> acc = [{1, 0}, {1, 0}, {1, 0}, {0, 1}, {1, 0}]
      iex> entry = [{0, 1}, {0, 1}, {0, 1}, {0, 1}, {1, 0}]
      iex> Diagnostic.add_bucket_entries(entry, acc)
      [{1, 1}, {1, 1}, {1, 1}, {0, 2}, {2, 0}]
  """
  def add_bucket_entries(a, b) do
    Enum.zip(a, b)
    |> Enum.map(fn {{az, ao}, {bz, bo}} -> {az + bz, ao + bo} end)
  end

  @doc """
  Compute gamma rate from tuple bucket sums.

  ## Examples
      iex> sums = [{5, 7}, {7, 5}, {4, 8}, {5, 7}, {7, 5}]
      iex> Diagnostic.gamma_rate(sums)
      22
  """
  def gamma_rate(sums) do
    Enum.map(sums, &Diagnostic.most_common/1)
    |> tuples_to_int
  end
  def most_common({zero, one}) when zero > one, do: bit_to_tuple(0)
  def most_common({zero, one}) when one >= zero, do: bit_to_tuple(1)

  @doc """
  Transform tuple buckets to integer.

  ## Examples
      iex> Diagnostic.gamma_rate([{1, 0}, {1, 0}, {1, 0}, {0, 1}, {1, 0}])
      2
      iex> Diagnostic.gamma_rate([{0, 1}, {0, 1}, {0, 1}, {0, 1}, {1, 0}])
      30
  """
  def tuples_to_int(tuples) do
    tuples
    |> Enum.reduce(0, fn (t, acc) ->
      acc * 2 + tuple_to_bit(t)
    end)
  end
  defp tuple_to_bit(t) when t == {1, 0}, do: 0
  defp tuple_to_bit(t) when t == {0, 1}, do: 1

  @doc """
  Compute epsilon rate from tuple bucket sums.

  ## Examples
      iex> sums = [{5, 7}, {7, 5}, {4, 8}, {5, 7}, {7, 5}]
      iex> Diagnostic.epsilon_rate(sums)
      9
  """
  def epsilon_rate(sums) do
    Enum.map(sums, &Diagnostic.least_common/1)
    |> tuples_to_int
  end
  def least_common({zero, one}) when zero <= one, do: bit_to_tuple(0)
  def least_common({zero, one}) when one < zero, do: bit_to_tuple(1)

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
  """
  def compute_life_support_ratings(entries) do
    bucket_entries = entries
                     |> Stream.map(&Diagnostic.bucketize_bits/1)
    o2 = o2_rating(bucket_entries)
    co2 = co2_rating(bucket_entries)
    {o2, co2}
  end

  @doc """
  Compute O₂ rating from tuple bucket entries.

  ## Examples
      iex> entries = [[1, 0, 0], [1, 1, 0], [0, 1, 0]]
      iex> Enum.map(entries, &Diagnostic.bucketize_bits/1) |> Diagnostic.o2_rating
      6
  """
  def o2_rating(bucket_entries), do: o2_rating(bucket_entries, 0)
  def o2_rating(bucket_entries, bit) do
    # sum tuple bucket entries, and find most common `bit`
    filter_bit = bucket_entries
                 |> Diagnostic.sum_bucket_entries()
                 |> Enum.map(&Diagnostic.most_common/1)
                 |> Enum.at(bit)
    # filter tuple bucket entries and keep those matching
    # most common `bit`
    filtered = bucket_entries
               |> Enum.filter(fn entry -> Enum.at(entry, bit) == filter_bit end)
    # if more than one left, continue to next `bit` using
    # tail recursion; otherwise, return the one as an
    # integer
    if Enum.count(filtered) == 1 do
      Enum.at(filtered, 0)
      |> tuples_to_int
    else
      o2_rating(filtered, bit + 1)
    end
  end

  @doc """
  Compute CO₂ rating from tuple bucket entries.

  ## Examples
      iex> entries = [[1, 0, 0], [1, 1, 0], [0, 1, 0]]
      iex> Enum.map(entries, &Diagnostic.bucketize_bits/1) |> Diagnostic.co2_rating
      2
  """
  def co2_rating(bucket_entries), do: co2_rating(bucket_entries, 0)
  def co2_rating(bucket_entries, bit) do
    # sum tuple bucket entries, and find least common `bit`
    filter_bit = bucket_entries
                 |> Diagnostic.sum_bucket_entries()
                 |> Enum.map(&Diagnostic.least_common/1)
                 |> Enum.at(bit)
    # filter tuple bucket entries and keep those matching
    # least common `bit`
    filtered = bucket_entries
               |> Enum.filter(fn entry -> Enum.at(entry, bit) == filter_bit end)
    # if more than one left, continue to next `bit` using
    # tail recursion; otherwise, return the one as an
    # integer
    if Enum.count(filtered) == 1 do
      Enum.at(filtered, 0)
      |> tuples_to_int
    else
      co2_rating(filtered, bit + 1)
    end
  end
end
