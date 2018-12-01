# "Streams are composable, lazy enumerables"
stream = File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)

freqsum = Enum.reduce(stream, fn(i, sum) -> i + sum end)
IO.inspect(freqsum)
