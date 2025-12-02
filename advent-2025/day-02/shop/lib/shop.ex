defmodule Shop do
  @moduledoc """
  Documentation for `Shop`.
  """

  import Shop.Parser
  import History.CLI

  @doc """
  Return the sum of all product IDs within a product ID range which
  contain a doubled digit pattern.

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
  Return the sum of all product IDs within a product ID range which
  contain a digit pattern repeated N times.

  ## Parameters

  - `range`: the product ID range
  """
  # FIXME use `product_range()` type
  @spec sum_repeated({integer(), integer()}) :: integer()
  def sum_repeated(range) do
    Range.new(elem(range, 0), elem(range, 1))
    |> Enum.map(fn id ->
      if is_repeated?(id), do: id, else: 0
    end)
    |> Enum.sum()
  end

  @doc """
  Does product ID contain a sequence of digits repeated N times?

  ## Parameters

  - `product_id`: the product ID (integer)

  ## Examples
      iex> Shop.is_repeated?(1)
      false
      iex> Shop.is_repeated?(12341234)
      true
      iex> Shop.is_repeated?(12312312)
      false
      iex> Shop.is_repeated?(123123123)
      true
      iex> Shop.is_repeated?(1212121212)
      true
      iex> Shop.is_repeated?(1111111)
      true
  """
  @spec is_repeated?(integer()) :: boolean()
  def is_repeated?(product_id) when product_id < 10, do: false
  def is_repeated?(product_id) do
    s = Integer.to_string(product_id)
    len = String.length(s)
    Range.new(1, div(len, 2))
    |> Enum.to_list()
    |> Enum.any?(fn n -> is_repeated_n?(s, len, n) end)
  end

  defp is_repeated_n?(s, len, n) do
    if rem(len, n) == 0 do
      [first | peers] = String.to_charlist(s)
                        |> Enum.chunk_every(n)
      Enum.all?(peers, fn peer -> peer == first end)
    else
      # can't be broken into equal pieces of length `n`
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
    |> Enum.map(&sum_repeated/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
