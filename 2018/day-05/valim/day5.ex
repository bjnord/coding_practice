# Puzzle: https://adventofcode.com/2018/day/5/answer
# Stream: https://www.twitch.tv/videos/345391561
defmodule Day5 do
  @doc """

      iex> Day5.react("dabAcCaCBAcCcaDA")
      "dabCBAcaDA"

  """
  def react(polymer) when is_binary(polymer) do
    discard_and_react(polymer, [], nil, nil)
  end

  @doc """

      iex> Day5.discard_and_react("dabAcCaCBAcCcaDA", ?A, ?a)
      "dbCBcD"

  """
  def discard_and_react(polymer, letter1, letter2) when is_binary(polymer) do
    discard_and_react(polymer, [], letter1, letter2)
  end

  defp discard_and_react(<<letter, rest::binary>>, acc, discard1, discard2)
       when letter == discard1
       when letter == discard2,
       do: discard_and_react(rest, acc, discard1, discard2)

  defp discard_and_react(<<letter1, rest::binary>>, [letter2 | acc], discard1, discard2)
       when abs(letter1 - letter2) == 32,
       do: discard_and_react(rest, acc, discard1, discard2)

  defp discard_and_react(<<letter, rest::binary>>, acc, discard1, discard2),
    do: discard_and_react(rest, [letter | acc], discard1, discard2)

  defp discard_and_react(<<>>, acc, _discard1, _discard2),
    do: acc |> Enum.reverse() |> List.to_string()

  @doc """

      iex> Day5.find_problematic("dabAcCaCBAcCcaDA")
      {?C, 4}

  """
  def find_problematic(polymer) do
    ?A..?Z
    |> Task.async_stream(fn letter ->
      {letter, byte_size(discard_and_react(polymer, letter, letter + 32))}
    end, ordered: false, max_concurrency: 26)
    |> Stream.map(fn {:ok, res} -> res end)
    |> Enum.min_by(&elem(&1, 1))
  end
end
