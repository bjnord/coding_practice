###
# read claims from input file (one per line)
# create a stream of lists of fabric squares used by each claim
###

file = "input/input.txt"
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

# Part 2 answer is: "1254"
Enum.reduce_while(restream, nil, fn (claim, _) ->
  count = Squares.highest_count(used, Squares.squares_used_by(claim))
  case count do
    1 -> {:halt, claim["claim"]}
    _ -> {:cont, nil}
  end
end)
|> IO.inspect(label: "Part 2 nonoverlapping claim ID is")
