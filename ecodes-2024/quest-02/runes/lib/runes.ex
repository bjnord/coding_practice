defmodule Runes do
  @moduledoc """
  Documentation for `Runes`.
  """

  import Kingdom.CLI
  import Runes.Parser

  @doc """
  Find matching rune word at beginning of inscription.
  """
  def begin_match?(words, chars) do
    words
    |> Enum.find(fn word ->
      Enum.slice(chars, 0, length(word)) == word
    end)
  end

  @doc """
  Find count of matching rune words in inscription.
  """
  def match_count(words, inscription) do
    i_chars = to_charlist(inscription)
    match_count(words, i_chars, 0)
  end

  defp match_count(_words, [], count), do: count
  defp match_count(words, i_chars, count) do
    case begin_match?(words, i_chars) do
      nil  -> match_count(words, tl(i_chars), count)
      _    -> match_count(words, tl(i_chars), count + 1)
    end
  end

  @doc """
  Find count of matching runes in inscription.
  """
  def rune_count(words, inscription) do
    i_chars = to_charlist(inscription)
    fwd = matching_runes(words, i_chars, [], 0)
    rev = matching_runes(words, Enum.reverse(i_chars), [], 0)
          |> Enum.map(fn r ->
            (length(i_chars) - 1) - r
          end)
    (fwd ++ rev)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp matching_runes(_words, [], runes, _index), do: runes
  defp matching_runes(words, i_chars, runes, index) do
    match = begin_match?(words, i_chars)
    runes =
      if match do
        index..(index+length(match)-1)
        |> Enum.reduce(runes, fn r, acc -> [r | acc] end)
      else
        runes
      end
    matching_runes(words, tl(i_chars), runes, index + 1)
  end

  def inscription_cols(inscriptions) do
    inscriptions
    |> Enum.map(&(to_charlist(&1)))
    # transpose: [h/t <https://stackoverflow.com/a/42887944/291754>]
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end

  defp solve(1) do
    {words, inscriptions} = parse_input_file(1)
    match_count(words, hd(inscriptions))
  end

  defp solve(2) do
    {words, inscriptions} = parse_input_file(2)
    inscriptions
    |> Enum.map(&(rune_count(words, &1)))
    |> Enum.sum()
  end

  def main(argv) do
    _opts = parse_args(argv)
    [1, 2]  # TODO `opts[:parts]`
    |> Enum.each(fn part ->
      solve(part)
      |> IO.inspect(label: "Part #{part}")
    end)
  end
end
