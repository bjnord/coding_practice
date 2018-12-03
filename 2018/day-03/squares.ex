defmodule Squares do
  # parse input line, returning claim map
  def parse(line) do
    Regex.named_captures(~r/#(?<claim>\d+)\s@\s(?<xs>\d+),(?<ys>\d+):\s(?<ws>\d+)x(?<hs>\d+)/, line)
  end

  # return list of all fabric squares used by claim map
  def squares_used_by(claims) do
    x = String.to_integer(claims["xs"])
    y = String.to_integer(claims["ys"])
    x_end = x + String.to_integer(claims["ws"]) - 1
    y_end = y + String.to_integer(claims["hs"]) - 1
    Enum.map(x..x_end, fn (i) -> Enum.map(y..y_end, fn (j) -> {i, j} end) end)
    |> List.flatten
  end

  # add list of fabric squares to count map, returning updated count map
  def count(counts, squares) do
    Enum.reduce(squares, counts, fn (sq, acc) -> Map.update(acc, sq, 1, &(&1 + 1)) end)
  end
end
