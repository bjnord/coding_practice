# Day 2: Inventory Management System
#
# Part 2: Find two box IDs that differ in only one letter (same position)
#         What letters are common between the two correct box IDs?
#
# Correct answer: "bvnfawcnyoeyudzrpgslimtkj"

# NOTE my solution assumes all box IDs will be the same length

###
# functions needed for main stream
###

# return index of the only pair in list with different values
# (return nil if more or less than one differing pair exists)
pair_comparator = fn (pairs) ->
                    diff = Enum.map(pairs, fn ({a, b}) -> if a == b, do: 0, else: 1 end)
                           |> Enum.sum
                    if diff == 1 do
                      Enum.find_index(pairs, fn ({a, b}) -> a != b end)
                    else
                      nil
                    end
                  end

# return position where strings differ, if they differ in exactly one position
# (return nil if they differ in more or less than one position)
str_comparator = fn (a, b) -> pair_comparator.(Enum.zip(String.graphemes(a), String.graphemes(b))) end

# return string with common characters between input strings
str_commonor = fn (a, b) ->
  Enum.zip(String.graphemes(a), String.graphemes(b))
  |> Enum.reduce([], fn ({l, r}, acc) -> if l == r, do: [l | acc], else: acc end)
  |> Enum.reverse
  |> List.to_string  # or Enum.join("")
end

###
# read box IDs from input file (one per line)
###

stream = File.stream!("input.txt")
|> Stream.map(&String.trim/1)

###
# find two box IDs that differ in only one letter (same position)
# keep a list of accumulated "seen" box IDs
###

accum = Enum.reduce_while(stream, {[], {}}, fn (next_s, {seen, _}) ->
          compares = Enum.map(seen, fn (seen_s) -> str_comparator.(seen_s, next_s) end)
          i = Enum.find_index(compares, fn (compare) -> compare != nil end)
          if i != nil do
            {:halt, {[next_s | seen], {Enum.at(seen, i), next_s}}}
          else
            {:cont, {[next_s | seen], {}}}
          end
        end)
{_, {id1, id2}} = accum

###
# display the letters in common between the two box IDs
###

common = str_commonor.(id1, id2)
IO.inspect(common)
