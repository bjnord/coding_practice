# I really recommend watching the videos, as the solution below
# is not the most elegant one but probably the most performant.
# We discuss the trade-offs here:
#
#  * https://www.twitch.tv/videos/344084005
#  * https://www.twitch.tv/videos/344091220
#
defmodule Day2 do
  def closest(list) when is_list(list) do
    list
    |> Enum.map(&String.to_charlist/1)
    |> closest_charlists()
  end

  def closest_charlists([head | tail]) do
    Enum.find_value(tail, &one_char_difference_string(&1, head)) ||
      closest_charlists(tail)
  end

  defp one_char_difference_string(charlist1, charlist2) do
    one_char_difference_string(charlist1, charlist2, [], 0)
  end

  defp one_char_difference_string([head | tail1], [head | tail2], same_acc, difference_count) do
    one_char_difference_string(tail1, tail2, [head | same_acc], difference_count)
  end

  defp one_char_difference_string([_ | tail1], [_ | tail2], same_acc, difference_count) do
    one_char_difference_string(tail1, tail2, same_acc, difference_count + 1)
  end

  defp one_char_difference_string([], [], same_acc, 1) do
    same_acc |> Enum.reverse() |> List.to_string()
  end

  defp one_char_difference_string([], [], _, _) do
    nil
  end

  def checksum(list) when is_list(list) do
    {twices, thrices} =
      Enum.reduce(list, {0, 0}, fn box_id, {total_twice, total_thrice} ->
        {twice, thrice} = box_id |> count_characters() |> get_twice_and_thrice()
        {twice + total_twice, thrice + total_thrice}
      end)

    twices * thrices
  end

  def get_twice_and_thrice(characters) when is_map(characters) do
    Enum.reduce(characters, {0, 0}, fn
      {_codepoint, 2}, {_twice, thrice} -> {1, thrice}
      {_codepoint, 3}, {twice, _thrice} -> {twice, 1}
      _, acc -> acc
    end)
  end

  def count_characters(string) when is_binary(string) do
    count_characters(string, %{})
  end

  defp count_characters(<<codepoint::utf8, rest::binary>>, acc) do
    acc = Map.update(acc, codepoint, 1, &(&1 + 1))
    count_characters(rest, acc)
  end

  defp count_characters(<<>>, acc) do
    acc
  end
end
