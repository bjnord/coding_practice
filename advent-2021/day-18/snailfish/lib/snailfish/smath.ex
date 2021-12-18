defmodule Snailfish.Smath do
  @moduledoc """
  Math for `Snailfish`.
  """

  alias Snailfish.Parser, as: Parser

  @doc ~S"""
  Add snailfish numbers.

  ## Examples
      iex> Snailfish.Smath.add(["[1,2]", "[[3,4],5]"])
      "[[1,2],[[3,4],5]]"
  """
  def add([n]), do: n
  def add([n1, n2]) do
    "[#{n1},#{n2}]"
    # TODO handle reduction here
  end
  def add([n1 | [n2 | numbers]]), do: add([add([n1, n2]) | numbers])

  @doc ~S"""
  Reduce snailfish number (in tokenized form).

  ## Examples
      iex> Snailfish.Smath.reduce([:o, 11, :s, 1, :c])
      "[[5,6],1]"
  """
  def reduce(tokens) when is_list(tokens) do
    i = find_splittable_index(tokens)
    case i do
      # no further reduction needed
      nil -> Parser.to_string(tokens)
      # split, and continue reducing
      _ -> reduce(split_at(tokens, i))
    end
  end

  @doc ~S"""
  Return index in `tokens` of leftmost splittable integer, or `nil` if none.

  "If any regular number is 10 or greater, the leftmost such regular number splits."

  ## Examples
      iex> tokens = Snailfish.Parser.to_tokens("[[1,2],[[3,4],5]]")
      iex> Snailfish.Smath.find_splittable_index(tokens)
      nil

      iex> tokens = [:o, :o, 1, :s, 2, :c, :s, :o, :o, 3, :s, 14, :c, :s, 5, :c, :c]
      iex> Snailfish.Smath.find_splittable_index(tokens)
      11
  """
  def find_splittable_index(tokens) when is_list(tokens) do
    Enum.find_index(tokens, &(splittable(&1)))
  end

  defp splittable(token) when is_integer(token) and token >= 10, do: true
  defp splittable(_token), do: false

  @doc ~S"""
  Split integer at `index` in `tokens`. Returns new `tokens`.

  "To split a regular number, replace it with a pair; the left element of
  the pair should be the regular number divided by two and rounded down,
  while the right element of the pair should be the regular number divided
  by two and rounded up."

  ## Examples
      iex> Snailfish.Smath.split_at([10], 0) |> Snailfish.Parser.to_string()
      "[5,5]"

      iex> Snailfish.Smath.split_at([:o, 11, :s, 1, :c], 1) |> Snailfish.Parser.to_string()
      "[[5,6],1]"

      iex> Snailfish.Smath.split_at([:o, 2, :s, 12, :c], 3) |> Snailfish.Parser.to_string()
      "[2,[6,6]]"
  """
  def split_at(tokens, i) when is_list(tokens) do
    {head, [n | tail]} = Enum.split(tokens, i)
    n1 = div(n, 2)
    n2 = n - n1
    sn = [:o, n1, :s, n2, :c]
    # TODO OPTIMIZE this is really inefficient:
    head ++ sn ++ tail
  end
end
