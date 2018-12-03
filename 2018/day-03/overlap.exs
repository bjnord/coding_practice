# Day 3: No Matter How You Slice It
#
# Part 1: How many square inches of fabric are within two or more claims?
#
# Correct answer: 117505

###
# read claims from input file (one per line)
# create a stream of lists of fabric squares used by each claim
###

stream = File.stream!("input.txt")
         |> Stream.map(&Squares.parse/1)
         |> Stream.map(&Squares.squares_used_by/1)

###
# combine the lists of fabric squares used by all claims, with count of each
# reduce this to the number of fabric squares used twice or more
###

used = Enum.reduce(stream, %{}, fn (squares, acc) -> Squares.count(acc, squares) end)
n_used = Enum.reduce(used, 0, fn (square, acc) ->
           {_, count} = square
           if count >= 2, do: acc + 1, else: acc
         end)
IO.inspect(n_used)
