# Day 2: Inventory Management System
#
# Part 1: count how many letters appear twice, and how many appear thrice
#         checksum = twice-count * thrice-count
#
# Correct answer: ?

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

stream = File.stream!("test/example1.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.graphemes/1)
|> Stream.map(counter)
|> Stream.map(tupler)

# test/example1.txt produces:
#   {false, false}
#   {true, true}
#   {true, false}
#   {false, true}
#   {true, false}
#   {true, false}
#   {false, true}

Enum.map(stream, fn x -> IO.inspect(x) end)
