defmodule Shop do
  @moduledoc """
  Documentation for `Shop`.
  """

  import Decor.CLI
  import Shop.Parser

  @type product_range() :: {pos_integer(), pos_integer()}

  @doc """
  Return the sum of all product IDs within a product ID range which
  contain a doubled digit pattern.

  ## Parameters

  - `range`: the product ID range
  """
  @spec sum_doubled(product_range()) :: pos_integer()
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
  @spec is_doubled?(pos_integer()) :: boolean()
  def is_doubled?(product_id) do
    s = Integer.to_string(product_id)
    len = String.length(s)
    if rem(len, 2) == 0 do
      is_repeated_n?(s, len, div(len, 2))
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
  @spec sum_repeated(product_range()) :: pos_integer()
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
  @spec is_repeated?(pos_integer()) :: boolean()
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
      [first | peers] =
        String.to_charlist(s)
        |> Enum.chunk_every(n)
      Enum.all?(peers, fn peer -> peer == first end)
    else
      # can't be broken into equal pieces of length `n`
      false
    end
  end

  @doc """
  Return all lengths which equally divide a product ID.

  Examples
      iex> Shop.sublengths(1)
      [1]
      iex> Shop.sublengths(1111)
      [1, 2]
      iex> Shop.sublengths(111111111)
      [1, 3]
  """
  @spec sublengths(pos_integer()) :: [pos_integer()]
  def sublengths(product_id) do
    case Decor.Math.n_digits(product_id) do
      1 -> [1]
      2 -> [1]
      3 -> [1]
      4 -> [1, 2]
      5 -> [1]
      6 -> [1, 2, 3]
      7 -> [1]
      8 -> [1, 2, 4]
      9 -> [1, 3]
      10 -> [1, 2, 5]
    end
  end

  @doc """
  Break product ID range into ranges with equal product ID lengths.

  Examples
      iex> Shop.break_range({1211, 1213})
      [{1211, 1213}]
      iex> Shop.break_range({9897, 10003})
      [{10000, 10003}, {9897, 9999}]
      iex> Shop.break_range({9897, 100004})
      [{100000, 100004}, {10000, 99999}, {9897, 9999}]
  """
  @spec break_range(product_range()) :: [product_range()]
  def break_range(range) do
    Stream.cycle([true])
    |> Enum.reduce_while({range, []}, fn _, {{lo, hi}, ranges} ->
      if Decor.Math.n_digits(lo) == Decor.Math.n_digits(hi) do
        {:halt, {{nil, nil}, [{lo, hi} | ranges]}}
      else
        next_lo = 10 ** Decor.Math.n_digits(lo)
        new_hi = next_lo - 1
        {:cont, {{next_lo, hi}, [{lo, new_hi} | ranges]}}
      end
    end)
    |> elem(1)
  end

  @doc """
  Find product IDs within the given range which have a repeating pattern.

  Examples
      iex> Shop.find_repeating({1211, 1213})
      [1212]
      iex> Shop.find_repeating({99000, 102101}) |> Enum.sort()
      [99999, 100100, 101010, 101101]
  """
  @spec find_repeating(product_range()) :: [pos_integer()]
  def find_repeating(range) do
    break_range(range)
    |> Enum.map(&find_eq_digits_repeating/1)
    |> List.flatten()
  end

  @spec find_eq_digits_repeating(product_range()) :: [[pos_integer()]]
  defp find_eq_digits_repeating({lo, hi}) do
    # `lo` and `hi` will have an equal number of digits
    sublengths(lo)
    |> Enum.map(fn sublen -> find_sublength_repeating({lo, hi}, sublen) end)
  end

  @spec find_sublength_repeating(product_range(), pos_integer()) :: [pos_integer()]
  defp find_sublength_repeating({lo, hi}, sublen) do
    # `lo` and `hi` will have an equal number of digits
    n_digits = Decor.Math.n_digits(lo)
    lo_patt = first_n_digits(lo, sublen)
    hi_patt = first_n_digits(hi, sublen)
    for patt <- lo_patt..hi_patt,
      id = repeat_patt(patt, div(n_digits, sublen)),
      in_range?({lo, hi}, id),
      into: [],
      do: id
  end

  @spec first_n_digits(pos_integer(), pos_integer()) :: pos_integer()
  defp first_n_digits(i, n) do
    Integer.to_string(i)
    |> String.slice(0, n)
    |> String.to_integer()
  end

  @doc """
  Repeat a pattern of digits `n` times.

  Examples
      iex> Shop.repeat_patt(12, 4)
      12121212
      iex> Shop.repeat_patt(123, 3)
      123123123
      iex> Shop.repeat_patt(1, 7)
      1111111
  """
  @spec repeat_patt(pos_integer(), pos_integer()) :: pos_integer()
  def repeat_patt(patt, n) do
    pow = 10 ** Decor.Math.n_digits(patt)
    1..n
    |> Enum.reduce(0, fn _, acc -> acc * pow + patt end)
  end

  @spec in_range?(product_range(), pos_integer()) :: boolean()
  defp in_range?({lo, hi}, n) do
    (lo <= n) && (n <= hi)
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
