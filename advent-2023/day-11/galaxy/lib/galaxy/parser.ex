defmodule Galaxy.Parser do
  @moduledoc """
  Parsing for `Galaxy`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a list of galaxy positions (`{y, x}` tuples).
  """
  def parse_input(input_file, _opts \\ []) do
    File.read!(input_file)
    |> parse_input_string()
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of galaxy positions (`{y, x}` tuples).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(&parse_line/1)
    |> List.flatten()
  end

  @doc ~S"""
  Parse an input line containing galaxy image data (`#` characters).

  ## Parameters

  `line` - input line
  `y` - y position (integer)

  Returns a list of galaxy positions (`{y, x}` tuples).

  ## Examples
      iex> parse_line({".#..#\n", 0})
      [{0, 1}, {0, 4}]
      iex> parse_line({".....\n", 1})
      []
      iex> parse_line({"#....\n", 2})
      [{2, 0}]
  """
  def parse_line({line, y}) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.filter(fn {ch, _x} -> ch == ?# end)
    |> Enum.map(fn {_ch, x} -> {y, x} end)
  end
end
