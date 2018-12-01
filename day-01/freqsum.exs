# Day 1: Chronal Calibration
#
# Part 1: Starting with a frequency of zero, what is the resulting frequency after all of the changes in frequency have been applied?
#
# Correct answer: 406

###
# read frequency changes from input file (one per line)
# create a stream of *integers*
###

# "Streams are composable, lazy enumerables"
stream = File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)

###
# reduce the stream to an accumulated sum
###

freqsum = Enum.sum(stream)
IO.inspect(freqsum)
