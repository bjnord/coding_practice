###
# functions needed for main stream
###

# count occurrences in a list
# e.g. counting ["a", "b", "a"]  yields %{"a" => 2, "b" => 1}
# h/t <https://stackoverflow.com/a/43007740/291754>
counter = fn (list) -> list |> Enum.reduce(%{}, fn (x, acc) -> Map.update(acc, x, 1, &(&1 + 1)) end) end

# return true if countmap has any entry with given value
detector = fn (countmap, value) -> Map.values(countmap) |> Enum.member?(value) end

# return tuple with binary values {has-value-twice, has-value-thrice}
tupler = fn (countmap) -> { detector.(countmap, 2), detector.(countmap, 3) } end

###
# read box IDs from input file (one per line)
# produce a stream of tuples w/binary values {has-letter-twice, has-letter-thrice}
###

stream = File.stream!("input/input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.graphemes/1)
|> Stream.map(counter)
|> Stream.map(tupler)

###
# reduce the stream of binary has-2/has-3 tuples
# to a single tuple with counts of ID-with-letter-twice, ID-with-letter-thrice
# and calculate the checksum
###

{has2, has3} = Enum.reduce(stream, {0, 0}, fn (tuple, {acc2, acc3}) ->
                 case tuple do
                   {true, true} -> {acc2 + 1, acc3 + 1}
                   {true, false} -> {acc2 + 1, acc3}
                   {false, true} -> {acc2, acc3 + 1}
                   {_, _} -> {acc2, acc3}
                 end
               end)

# Part 1 answer is: 6696
IO.inspect(has2 * has3, label: "Part 1 checksum is")
