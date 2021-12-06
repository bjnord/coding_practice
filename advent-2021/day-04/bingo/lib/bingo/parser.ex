defmodule Bingo.Parser do
  @moduledoc """
  Parsing for `Bingo`.
  """

  @doc ~S"""
  Parse the input file.

  Returns `{balls, boards}` where the former is a list, and the latter is a list of lists.
  """
  def parse_input(input, _opts \\ []) do
    [ball_tok | board_tok] = input
                             |> String.split
    balls = ball_tok
            |> String.split(",")
            |> Enum.map(&String.to_integer/1)
    boards = board_tok
             |> Enum.map(&String.to_integer/1)
             |> Enum.chunk_every(25)
             |> Enum.map(fn squares -> {squares, 0b0, nil} end)
    {balls, boards}
  end
end
