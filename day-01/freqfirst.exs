# Day 1: Chronal Calibration
#
# Part 2: (Given a repeating set of frequency changes:) What is the first frequency your device reaches twice?
#
# Correct answer: 312

###
# read frequency changes from input file (one per line)
# treat them as a repeating list (with "cycle")
# and map them to accumulated frequencies
#
# i.e. input:  +1 +2 -1 +3
#      stream:  1  3  2  5  6  8  7 10 ...
###

# "Streams are composable, lazy enumerables"
stream = File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Stream.cycle
|> Stream.scan(fn(i, sum) -> i + sum end)

###
# find the first frequency value that repeats
# keep a map of accumulated "seen" values
###

accum = Enum.reduce_while(stream, {%{0 => true}, 0, false}, fn(i, {seen, value, found}) ->
          case {seen[i], found} do
            {_, true}     -> {:halt, {seen, value, found}}
            {true, false} -> {:cont, {seen, i, true}}
            {_, _}        -> {:cont, {Map.put(seen, i, true), value, false}}
          end
        end)
{_, first, _} = accum
IO.inspect(first)
