###
# read frequency changes from input file (one per line)
# treat them as a repeating list (with "cycle")
# and map them to accumulated frequencies (with "scan")
#
# i.e. input:  +1 +2 -1 +3
#      stream:  1  3  2  5  6  8  7 10 ...
###

# "Streams are composable, lazy enumerables"
stream = File.stream!("input/input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Stream.cycle
|> Stream.scan(fn(i, sum) -> i + sum end)

###
# find the first frequency value that repeats
# keep a map of accumulated "seen" values
###

# Part 2 answer is: 312
Enum.reduce_while(stream, {%{0 => true}, 0}, fn(i, {seen, _}) ->
 if seen[i], do: {:halt, {seen, i}}, else: {:cont, {Map.put(seen, i, true), 0}}
end)
|> elem(1)
|> IO.inspect(label: "Part 2 frequency repeat is")
