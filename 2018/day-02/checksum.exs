defmodule Inventory do
  @moduledoc """
  Documentation for Inventory.
  """

  @doc """
  Count occurrences in a list.

  e.g. counting ["a", "b", "a"]  yields %{"a" => 2, "b" => 1}
  h/t <https://stackoverflow.com/a/43007740/291754>
  """
  def count(list) do
    Enum.reduce(list, %{}, fn (x, acc) -> Map.update(acc, x, 1, &(&1 + 1)) end)
  end

  @doc """
  Return true if countmap has any entry with given value.
  """
  def has_value?(countmap, value) do
    Map.values(countmap)
    |> Enum.member?(value)
  end

  @doc """
  Return tuple with binary values {has-value-twice, has-value-thrice}.
  """
  def two_and_three?(countmap) do
    { has_value?(countmap, 2), has_value?(countmap, 3) }
  end

  @doc """
  Return tuple with binary values {has-value-twice, has-value-thrice}.
  """
  def count_2s_3s(stream) do
    Enum.reduce(stream, {0, 0}, fn (tuple, {acc2, acc3}) ->
      case tuple do
        {true, true} -> {acc2 + 1, acc3 + 1}
        {true, false} -> {acc2 + 1, acc3}
        {false, true} -> {acc2, acc3 + 1}
        {_, _} -> {acc2, acc3}
      end
    end)
  end
end

###
# read box IDs from input file (one per line)
# produce a stream of tuples w/binary values {has-letter-twice, has-letter-thrice}
###

stream = File.stream!("input/input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.graphemes/1)
|> Stream.map(&Inventory.count/1)
|> Stream.map(&Inventory.two_and_three?/1)

###
# reduce the stream of binary has-2/has-3 tuples
# to a single tuple with counts of ID-with-letter-twice, ID-with-letter-thrice
# and calculate the checksum
###

{has2, has3} = Inventory.count_2s_3s(stream)

# Part 1 answer is: 6696
IO.inspect(has2 * has3, label: "Part 1 checksum is")
