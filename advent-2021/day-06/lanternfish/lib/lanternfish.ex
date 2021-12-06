defmodule Lanternfish do
  @moduledoc """
  Documentation for Lanternfish.
  """

  import Lanternfish.Parser
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
    |> to_buckets()
    |> generate(80)
    |> tuple_sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Put `fish` into buckets by timer value.

  Returns a tuple in which each element is a count of fish with that timer value.

  ## Examples
      iex> Lanternfish.to_buckets([8, 1, 5, 1, 8, 1, 2, 0, 2])
      {1, 3, 2, 0, 0, 1, 0, 0, 2}
  """
  def to_buckets(fish) do
    fish
    |> Enum.reduce({0, 0, 0, 0, 0, 0, 0, 0, 0}, fn (fish, buckets) ->
      put_elem(buckets, fish, elem(buckets, fish) + 1)
    end)
  end

  @doc """
  Simulate lanternfish generation.

  Returns final `buckets` after `days` days of generation.
  """
  def generate(buckets, days), do: generate(buckets, days, 0)
  def generate(buckets, days, day) when day == days, do: buckets
  def generate(buckets, days, day) do
    gen_count = elem(buckets, 0)
    buckets
    |> Tuple.delete_at(0)
    |> put_elem(6, elem(buckets, 7) + gen_count)
    |> Tuple.append(gen_count)
    |> generate(days, day + 1)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> to_buckets()
    |> generate(256)
    |> tuple_sum()
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Return sum of tuple values.
  FIXME `Tuple.sum/1` is available in later versions of Elixir.
  """
  def tuple_sum(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.sum()
  end
end
