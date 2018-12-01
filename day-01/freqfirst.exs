# "Streams are composable, lazy enumerables"
stream = File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Stream.cycle
|> Stream.scan(fn(i, sum) -> i + sum end)

accum = Enum.reduce_while(stream, {%{0 => true}, 0, false}, fn(i, {seen, value, found}) ->
          case {seen[i], found} do
            {_, true}     -> {:halt, {seen, value, found}}
            {true, false} -> {:cont, {seen, i, true}}
            {_, _}        -> {:cont, {Map.put(seen, i, true), value, false}}
          end
        end)
{_, first, _} = accum
IO.inspect(first)
