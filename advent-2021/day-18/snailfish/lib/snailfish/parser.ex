defmodule Snailfish.Parser do
  @moduledoc """
  Parsing for `Snailfish`.
  """

  @doc ~S"""
  Convert snailfish number string to list of tokens.

  ## Examples
      iex> Snailfish.Parser.to_tokens("[[1,2],[[3,4],5]]")
      [:o, :o, 1, :s, 2, :c, :s, :o, :o, 3, :s, 4, :c, :s, 5, :c, :c]
  """
  def to_tokens(number) do
    number
    |> String.to_charlist()
    |> Enum.map(fn ch ->
      case ch do
        ?[ -> :o
        ?] -> :c
        ?, -> :s
        ch when ch in ?0..?9 -> ch - ?0
      end
    end)
  end

  @doc ~S"""
  Convert snailfish tokenized number back to number string.

  ## Examples
      iex> Snailfish.Parser.to_string([:o, :o, 1, :s, 2, :c, :s, :o, :o, 3, :s, 4, :c, :s, 5, :c, :c])
      "[[1,2],[[3,4],5]]"
  """
  def to_string(tokens) do
    tokens
    |> Enum.map(fn t ->
      case t do
        :o -> ?[
        :c -> ?]
        :s -> ?,
        t when t in 0..9 -> t + ?0
      end
    end)
    |> (fn cl -> Kernel.to_string(cl) end).()
  end
end
