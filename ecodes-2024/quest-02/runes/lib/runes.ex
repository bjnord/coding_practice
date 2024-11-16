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
      word_ch = to_charlist(word)
      Enum.slice(chars, 0, length(word_ch)) == word_ch
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

  def main(argv) do
    _opts = parse_args(argv)
    [1]  # TODO `opts[:parts]`
    |> Enum.each(fn part ->
      {words, inscription} =
        "private/everybody_codes_e2024_q02_p#{part}.txt"
        |> parse_input()
      match_count(words, inscription)
      |> IO.inspect(label: "Part #{part}")
    end)
  end
end
