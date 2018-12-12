defmodule Inventory do
  @moduledoc """
  Documentation for Inventory.

  NOTE solution assumes all box IDs will be the same length
  """

  @doc """
  Return index of the only pair in list with different values.
  (Return `nil` if more or less than one differing pair exists.)
  """
  def compare_pairs(pairs) do
    diff = Enum.map(pairs, fn ({a, b}) -> if a == b, do: 0, else: 1 end)
           |> Enum.sum
    case diff do
      1 -> Enum.find_index(pairs, fn ({a, b}) -> a != b end)
      _ -> nil
    end
  end

  @doc """
  Return position where strings differ, if they differ in exactly one position.
  (Return `nil` if they differ in more or less than one position.)
  """
  def compare_strings(a, b) do
    Enum.zip(String.graphemes(a), String.graphemes(b))
    |> Inventory.compare_pairs()
  end

  @doc """
  Return string with common characters between input strings.
  """
  def common_characters(a, b) do
    Enum.zip(String.graphemes(a), String.graphemes(b))
    |> Enum.reduce([], fn ({l, r}, acc) -> if l == r, do: [l | acc], else: acc end)
    |> Enum.reverse
    |> List.to_string  # or Enum.join("")
  end

  @doc """
  Return the two box IDs that differ in only one letter (same position).
  """
  def comparable_box_ids(stream) do
    Enum.reduce_while(stream, [], fn (this_s, seen) ->
      compares = Enum.map(seen, fn (seen_s) -> Inventory.compare_strings(seen_s, this_s) end)
      i = Enum.find_index(compares, fn (compare) -> compare != nil end)
      case i do
        nil -> {:cont, [this_s | seen]}
        i   -> {:halt, {Enum.at(seen, i), this_s}}
      end
    end)
  end
end

###
# read box IDs from input file (one per line)
###

stream = File.stream!("input/input.txt")
         |> Stream.map(&String.trim/1)

###
# find two box IDs that differ in only one letter (same position)
###

{id1, id2} = Inventory.comparable_box_ids(stream)

###
# display the letters in common between the two box IDs
###

# Part 2 answer is: "bvnfawcnyoeyudzrpgslimtkj"
Inventory.common_characters(id1, id2)
|> IO.inspect(label: "Part 2 letters in common are")
