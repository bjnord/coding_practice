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
  Find count of matching runes in inscription.
  """
  def rune_count(words, irunes) do
    count = length(irunes)
    fwd = matching_runes(words, irunes, [], 0, count)
    rev = matching_runes(words, Enum.reverse(irunes), [], 0, count)
          |> Enum.map(fn r ->
            (count - 1) - r
          end)
    (fwd ++ rev)
    |> Enum.uniq()
    |> Enum.count()
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

  defp solve(1) do
    {words, inscriptions} = parse_input_file(1)
    word_count(words, hd(inscriptions))
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
