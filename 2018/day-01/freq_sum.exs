###
# read frequency changes from input file (one per line)
# create a stream of *integers*
###

# "Streams are composable, lazy enumerables"
stream = File.stream!("input/input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)

###
# reduce the stream to an accumulated sum
###

# Part 1 answer is: 406
Enum.sum(stream)
|> IO.inspect(label: "Part 1 frequency sum is")
