defmodule YardTest do
  use ExUnit.Case
  doctest Yard

  import Yard

  test "strange magic" do
    yard_0 = parse_lines([
      ".#.#...|#.",
      ".....#|##|",
      ".|..|...#.",
      "..|#.....#",
      "#.#|||#|#|",
      "...#.||...",
      ".|....|...",
      "||...#|.#|",
      "|.||||..|.",
      "...#.|..|.",
    ])
    yard_1 = parse_lines([
      ".......##.",
      "......|###",
      ".|..|...#.",
      "..|#||...#",
      "..##||.|#|",
      "...#||||..",
      "||...|||..",
      "|||||.||.|",
      "||||||||||",
      "....||..|.",
    ])
    yard_1_result = strange_magic(yard_0, 1)
#   Yard.map(yard_1, label: "<<<<< expected minutes=1")
#   |> Enum.map(fn (line) -> IO.puts(line) end)
#   Yard.map(yard_1_result, label: ">>>>> actual minutes=1")
#   |> Enum.map(fn (line) -> IO.puts(line) end)
    assert yard_1_result == yard_1

    yard_10 = parse_lines([
      ".||##.....",
      "||###.....",
      "||##......",
      "|##.....##",
      "|##.....##",
      "|##....##|",
      "||##.####|",
      "||#####|||",
      "||||#|||||",
      "||||||||||",
    ])
    yard_10_result = strange_magic(yard_0, 10)
#   Yard.map(yard_1, label: "<<<<< expected minutes=1")
#   |> Enum.map(fn (line) -> IO.puts(line) end)
#   Yard.map(yard_1_result, label: ">>>>> actual minutes=1")
#   |> Enum.map(fn (line) -> IO.puts(line) end)
    assert yard_10_result == yard_10
  end

  test "checksum" do
    yard_0 = parse_lines([
      ".#.#...|#.",
      ".....#|##|",
      ".|..|...#.",
      "..|#.....#",
      "#.#|||#|#|",
      "...#.||...",
      ".|....|...",
      "||...#|.#|",
      "|.||||..|.",
      "...#.|..|.",
    ])
    yard_1 = parse_lines([
      ".......##.",
      "......|###",
      ".|..|...#.",
      "..|#||...#",
      "..##||.|#|",
      "...#||||..",
      "||...|||..",
      "|||||.||.|",
      "||||||||||",
      "....||..|.",
    ])
    yard_1_checksum = checksum(yard_1)
    yard_1_result = strange_magic(yard_0, 1)
    yard_1_result_checksum = checksum(yard_1_result)
#   Yard.map(yard_1, label: "<<<<< expected minutes=1")
#   |> Enum.map(fn (line) -> IO.puts(line) end)
#   IO.puts("checksum: #{yard_1_checksum}")
#   Yard.map(yard_1_result, label: ">>>>> actual minutes=1")
#   |> Enum.map(fn (line) -> IO.puts(line) end)
#   IO.puts("checksum: #{yard_1_result_checksum}")
    assert yard_1_result_checksum == yard_1_checksum
  end
end
