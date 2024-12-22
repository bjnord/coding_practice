defmodule Monkey do
  @moduledoc """
  Documentation for `Monkey`.
  """

  import Bitwise
  import History.CLI

  def next_numbers(secret, count) do
    1..count
    |> Enum.reduce({secret, []}, fn _, {next, acc} ->
      next = next_number(next)
      {next, [next | acc]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  def nth_buyer_numbers(buyer_secrets, count) do
    buyer_secrets
    |> Enum.map(fn buyer_secret ->
      next_numbers(buyer_secret, count)
      |> Enum.at(count - 1)
    end)
  end

  # In particular, each buyer's secret number evolves into the next secret
  # number in the sequence via the following process:
  #
  # - Calculate the result of multiplying the secret number by 64. Then,
  #   mix this result into the secret number. Finally, prune the secret
  #   number.
  # - Calculate the result of dividing the secret number by 32. Round
  #   the result down to the nearest integer. Then, mix this result into
  #   the secret number. Finally, prune the secret number.
  # - Calculate the result of multiplying the secret number by 2048. Then,
  #   mix this result into the secret number. Finally, prune the secret
  #   number.

  def next_number(a) do
    b = mix(a, a * 64)
        |> prune()
    c = mix(b, div(b, 32))
        |> prune()
    mix(c, c * 2048)
    |> prune()
  end

  # Each step of the above process involves mixing and pruning:
  #
  # - To mix a value into the secret number, calculate the bitwise XOR of
  #   the given value and the secret number. Then, the secret number
  #   becomes the result of that operation. (If the secret number is 42
  #   and you were to mix 15 into the secret number, the secret number
  #   would become 37.)
  # - To prune the secret number, calculate the value of the secret number
  #   modulo 16777216. Then, the secret number becomes the result of that
  #   operation. (If the secret number is 100000000 and you were to prune
  #   the secret number, the secret number would become 16113920.)

  @doc """
  Mix a value into the secret number.

  ## Examples
      iex> mix(42, 15)
      37
  """
  def mix(i, j), do: bxor(i, j)

  @doc """
  Prune the secret number.

  ## Examples
      iex> prune(100000000)
      16113920
  """
  def prune(i), do: rem(i, 16777216)

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
    File.read!(input_path)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> nth_buyer_numbers(2000)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    File.read!(input_path)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
