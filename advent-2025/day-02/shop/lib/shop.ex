defmodule Shop do
  @moduledoc """
  Documentation for `Shop`.
  """

  import Shop.Parser
  import History.CLI

  @doc """
  Return the sum of all doubled product IDs within a product ID range.

  ## Parameters

  - `range`: the product ID range
  """
  # FIXME use `product_range()` type
  @spec sum_doubled({integer(), integer()}) :: integer()
  def sum_doubled(range) do
    Range.new(elem(range, 0), elem(range, 1))
    |> Enum.map(fn id ->
      if is_doubled?(id), do: id, else: 0
    end)
    |> Enum.sum()
  end

  @doc """
  Does product ID contain a sequence of digits repeated twice?

  ## Parameters

  - `product_id`: the product ID (integer)

  ## Examples
      iex> Shop.is_doubled?(55)
      true
      iex> Shop.is_doubled?(56)
      false
      iex> Shop.is_doubled?(646)
      false
      iex> Shop.is_doubled?(6464)
      true
      iex> Shop.is_doubled?(123123)
      true
  """
  @spec is_doubled?(integer()) :: boolean()
  def is_doubled?(product_id) do
    s = Integer.to_string(product_id)
    len = String.length(s)
    if rem(len, 2) == 0 do
      l = String.slice(s, 0, div(len, 2))
      r = String.slice(s, div(len, 2), div(len, 2))
      l == r
    else
      false
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
    parse_input_file(input_path)
    |> Enum.map(&sum_doubled/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
