# NOTE solution assumes all box IDs will be the same length

###
# functions needed for main stream
###

# return index of the only pair in list with different values
# (return nil if more or less than one differing pair exists)
pair_comparator = fn (pairs) ->
                    diff = Enum.map(pairs, fn ({a, b}) -> if a == b, do: 0, else: 1 end)
                           |> Enum.sum
                    case diff do
                      1 -> Enum.find_index(pairs, fn ({a, b}) -> a != b end)
                      _ -> nil
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

stream = File.stream!("input/input.txt")
|> Stream.map(&String.trim/1)

###
# find two box IDs that differ in only one letter (same position)
# keep a list of accumulated "seen" box IDs
###

{id1, id2} = Enum.reduce_while(stream, [], fn (this_s, seen) ->
               compares = Enum.map(seen, fn (seen_s) -> str_comparator.(seen_s, this_s) end)
               i = Enum.find_index(compares, fn (compare) -> compare != nil end)
               case i do
                 nil -> {:cont, [this_s | seen]}
                 i   -> {:halt, {Enum.at(seen, i), this_s}}
               end
             end)

###
# display the letters in common between the two box IDs
###

# Part 2 answer is: "bvnfawcnyoeyudzrpgslimtkj"
str_commonor.(id1, id2)
|> IO.inspect(label: "Part 2 letters in common are")
