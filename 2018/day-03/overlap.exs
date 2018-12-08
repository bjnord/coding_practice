# Day 3: No Matter How You Slice It
#
# Part 1: How many square inches of fabric are within two or more claims?
#

###
# read claims from input file (one per line)
# create a stream of lists of fabric squares used by each claim
###

stream = File.stream!("input/input.txt")
         |> Stream.map(&Squares.parse/1)
         |> Stream.map(&Squares.squares_used_by/1)

###
# combine the lists of fabric squares used by all claims, with count of each
# reduce this to the number of fabric squares used twice or more
###

# Part 1 answer is: 117505
Enum.reduce(stream, %{}, fn (squares, acc) -> Squares.count(acc, squares) end)
|> Enum.reduce(0, fn (square, acc) ->
  {_, count} = square
  if count >= 2, do: acc + 1, else: acc
end)
|> IO.inspect(label: "Part 1 squares overlapping is")
