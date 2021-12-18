defmodule Bingo.Parser do
  @moduledoc """
  Parsing for `Bingo`.
  """

  @doc ~S"""
  Parse the input.

  ## Examples
      iex> balls = "2,3,5,7,11,13,17\n"
      iex> board1 = " 2  7  6\n 9  5  1\n 4  3  8\n"
      iex> board2 = " 7 12 11\n14 10  6\n 9  8 13\n"
      iex> Bingo.Parser.parse("#{balls}\n#{board1}\n#{board2}", dim: 3)
      {
        [2, 3, 5, 7, 11, 13, 17],
        [
          [2, 7, 6, 9, 5, 1, 4, 3, 8],
          [7, 12, 11, 14, 10, 6, 9, 8, 13],
        ],
      }
  """
  def parse(input, opts \\ []) do
    opts = Keyword.merge([dim: 5], opts)
    [token | tokens] = String.split(input)
    {parse_balls(token), parse_boards(tokens, opts[:dim])}
  end

  defp parse_balls(token) do
    token
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_boards(tokens, dim) do
    tokens
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(dim * dim)
  end
end
