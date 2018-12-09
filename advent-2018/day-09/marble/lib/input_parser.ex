defmodule InputParser do
  import NimbleParsec

  # "428 players; last marble is worth 72061 points"

  line =
    integer(min: 1)
    |> ignore(string(" players; last marble is worth "))
    |> integer(min: 1)
    |> ignore(string(" points"))

  defparsec :input_line, line
end
