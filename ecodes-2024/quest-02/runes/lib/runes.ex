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

  def main(argv) do
    _opts = parse_args(argv)
    [1]  # TODO `opts[:parts]`
    |> Enum.each(fn part ->
      {words, inscriptions} = parse_input_file(part)
      match_count(words, hd(inscriptions))
      |> IO.inspect(label: "Part #{part}")
    end)
  end
end
