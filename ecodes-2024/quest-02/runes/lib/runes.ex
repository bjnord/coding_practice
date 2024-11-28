defmodule Runes do
  @moduledoc """
  Documentation for `Runes`.
  """

  import Kingdom.CLI
  import Runes.Parser

  @doc """
  Find matching rune word at beginning of inscription.
  """
  def find_word(words, irunes) do
    words
    |> Enum.find(fn word ->
      Enum.slice(irunes, 0, length(word)) == word
    end)
  end

  @doc """
  Find count of matching rune words in inscription.

  (This finds matches in the forward direction only.)
  """
  def word_count(words, irunes) do
    word_count(words, irunes, 0)
  end

  defp word_count(_words, [], matches), do: matches
  defp word_count(words, irunes, matches) do
    case find_word(words, irunes) do
      nil  -> word_count(words, tl(irunes), matches)
      _    -> word_count(words, tl(irunes), matches + 1)
    end
  end

  @doc """
  Find matching runes in inscription.

  (This finds matches in the forward and reverse directions.)
  """
  def matching_runes(words, irunes, {dir, pos}) do
    fwd = matching_runes(words, irunes, [], 0, length(irunes))
          |> Enum.map(&({&1, dir, pos}))
    rev = matching_runes(words, Enum.reverse(irunes), [], 0, length(irunes))
          |> Enum.map(&({(length(irunes) - 1) - &1, dir, pos}))
    (fwd ++ rev)
    |> Enum.uniq()
  end

  defp matching_runes(_words, _irunes, matches, _index, 0), do: matches
  defp matching_runes(words, irunes, matches, index, count) do
    match = find_word(words, irunes)
    matches =
      if match do
        index..(index+length(match)-1)
        |> Enum.reduce(matches, fn r, acc -> [r | acc] end)
      else
        matches
      end
    matching_runes(words, tl(irunes), matches, index + 1, count - 1)
  end

  def inscription_cols(inscriptions) do
    inscriptions
    # transpose: [h/t <https://stackoverflow.com/a/42887944/291754>]
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end

  @doc """
  Find matching runes in inscription grid.

  (This finds matches in the forward and reverse directions, on both rows
  and columns, wrapping around horizontally.
  """
  def grid_matching_runes(words, inscriptions) do
    width = length(hd(inscriptions))
    row_runes =
      inscriptions
      |> Enum.map(&(&1 ++ &1))
      |> Enum.with_index()
      |> Enum.map(fn {inscription, row} ->
        matching_runes(words, inscription, {:row, row})
        |> Enum.map(fn {x, :row, y} -> {rem(x, width), y} end)
      end)
    col_runes =
      inscription_cols(inscriptions)
      |> Enum.with_index()
      |> Enum.map(fn {inscription, col} ->
        matching_runes(words, inscription, {:col, col})
        |> Enum.map(fn {y, :col, x} -> {x, y} end)
      end)
    (row_runes ++ col_runes)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp solve(1) do
    {words, inscriptions} = parse_input_file(1)
    word_count(words, hd(inscriptions))
  end

  defp solve(2) do
    {words, inscriptions} = parse_input_file(2)
    inscriptions
    |> Enum.with_index()
    |> Enum.map(fn {inscription, row} ->
      matching_runes(words, inscription, {:row, row})
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  defp solve(3) do
    {words, inscriptions} = parse_input_file(2)
    grid_matching_runes(words, inscriptions)
    |> Enum.count()
  end

  def main(argv) do
    opts = parse_args(argv)
    opts[:parts]
    |> Enum.each(fn part ->
      solve(part)
      |> IO.inspect(label: "Part #{part}")
    end)
  end
end
