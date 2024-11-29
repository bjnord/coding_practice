defmodule Earth.Parser do
  @moduledoc """
  Parsing for `Earth`.
  """

  alias Kingdom.Grid

  @type option() :: {:debug, boolean()}

  @doc ~S"""
  Parse the input from a file.

  ## Parameters

  - `f`: the puzzle input file descriptor (part number or filename)
  - `opts`: the parsing options

  Returns a `Grid`.
  """
  @spec parse_input_file(pos_integer() | String.t(), [option()]) :: Grid.t()
  def parse_input_file(f, opts \\ [])
  def parse_input_file(f, opts) when is_integer(f) do
    "private/everybody_codes_e2024_q03_p#{f}.txt"
    |> File.read!()
    |> parse_input_string(opts)
  end
  def parse_input_file(f, opts) do
    File.read!(f)
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse the input from a string.

  ## Parameters

  - `input`: the puzzle input
  - `opts`: the parsing options

  Returns a `Grid`.
  """
  @spec parse_input_string(String.t(), [option()]) :: Grid.t()
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(&parse_line/1)
    |> Grid.from_squares()
  end

  @doc ~S"""
  Parse an input line containing earth square characters.

  ## Parameters

  - `line`: the input line
  - `y`: the y position (integer) of the input line

  Returns the earth square depth values and their positions, as a list of
  `{{y, x}, depth}` tuples.

  ## Examples
      iex> parse_line({".....\n", 0})
      [{{0, 0}, 0}, {{0, 1}, 0}, {{0, 2}, 0}, {{0, 3}, 0}, {{0, 4}, 0}]
      iex> parse_line({".###.\n", 1})
      [{{1, 0}, 0}, {{1, 1}, 1}, {{1, 2}, 1}, {{1, 3}, 1}, {{1, 4}, 0}]
  """
  def parse_line({line, y}) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.map(fn {ch, x} -> {{y, x}, parse_char(ch)} end)
  end

  defp parse_char(ch) do
    case ch do
      ?. -> 0
      ?# -> 1
      _  -> raise "unknown grid square char #{ch}"
    end
  end
end
