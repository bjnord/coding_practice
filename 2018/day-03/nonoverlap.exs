# Day 3: No Matter How You Slice It
#
# Part 2: What is the ID of the only claim that doesn't overlap?
#
# Correct answer: "1254"

###
# read claims from input file (one per line)
# create a stream of lists of fabric squares used by each claim
###

file = "input.txt"
stream = File.stream!(file)
         |> Stream.map(&Squares.parse/1)
         |> Stream.map(&Squares.squares_used_by/1)

###
# combine the lists of fabric squares used by all claims, with count of each
###

used = Enum.reduce(stream, %{}, fn (squares, acc) -> Squares.count(acc, squares) end)

###
# re-read claims from input file (one per line)
###

restream = File.stream!(file)
         |> Stream.map(&Squares.parse/1)

###
# compare each claim to the full list of fabric squares used
###

claim_id = Enum.reduce_while(restream, nil, fn (claim, _) ->
             if Squares.highest_count(used, Squares.squares_used_by(claim)) == 1 do
               {:halt, claim["claim"]}
             else
               {:cont, nil}
             end
           end)
IO.inspect(claim_id)
