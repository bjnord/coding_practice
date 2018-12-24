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
end
