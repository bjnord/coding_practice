defmodule Cube.Parser do
  @moduledoc """
  Parsing for `Cube`.
  """

  alias Cube.Game, as: Game

  @doc ~S"""
  Parse the input file.

  Returns a list of games (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of games (one per line).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a game.

  Returns a game.

  ## Examples
      iex> parse_line("Game 2: 2 blue, 1 green; 4 green, 3 red\n")
      %Cube.Game{id: 2, reveals: [%{blue: 2, green: 1}, %{green: 4, red: 3}]}
  """
  def parse_line(line) do
    [id_str, reveals_str] =
      line
      |> String.trim_trailing()
      |> String.split(":", trim: true)
    %Game{
      id: parse_id(id_str),
      reveals: parse_reveals(reveals_str),
    }
  end

  # "Game: 2"
  defp parse_id(id_str) do
    id_str
    |> String.split()
    |> List.last()
    |> String.to_integer()
  end

  # "2 blue, 1 green; 4 green, 3 red"
  defp parse_reveals(reveals_str) do
    reveals_str
    |> String.split(";", trim: true)
    |> Enum.map(&parse_reveal/1)
  end

  # "2 blue, 1 green"
  # Returns map: `%{blue: 2, green: 1}`
  defp parse_reveal(reveal_str) do
    reveal_str
    |> String.split(",", trim: true)
    |> Enum.map(&parse_reveal_pair/1)
    |> Enum.into(%{})
  end

  # "2 blue"
  # Returns tuple: `{:blue, 2}`
  defp parse_reveal_pair(reveal_pair_str) do
    [n, color] = reveal_pair_str
                 |> String.split()
    {
      String.to_atom(color),
      String.to_integer(n),
    }
  end
end
