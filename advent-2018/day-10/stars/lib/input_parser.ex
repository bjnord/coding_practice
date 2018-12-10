defmodule InputParser do
  import NimbleParsec

  # TODO this is little better than using regex matching
  #      learn how to write a "signed integer" element,
  #      ignore spaces, etc.

  defparsecp :input_line,
             ignore(string("position=<"))
             |> ascii_string([?\s, ?-, ?0..?9], min: 1)
             |> ignore(string(", "))
             |> ascii_string([?\s, ?-, ?0..?9], min: 1)
             |> ignore(string("> velocity=<"))
             |> ascii_string([?\s, ?-, ?0..?9], min: 1)
             |> ignore(string(", "))
             |> ascii_string([?\s, ?-, ?0..?9], min: 1)
             |> ignore(string(">"))

  @doc """
  Parses an input line.

  ## Examples

      iex> InputParser.parse_line("position=< 9,  1> velocity=< 0,  2>")
      {9, 1, 0, 2}

      iex> InputParser.parse_line("position=<-6, 10> velocity=< 2, -2>")
      {-6, 10, 2, -2}

      iex> InputParser.parse_line("position=<10, -3> velocity=<-1,  1>")
      {10, -3, -1, 1}

  """
  def parse_line(line) do
    {:ok, coords, _, _, _, _} = input_line(line)
    coords
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
end
