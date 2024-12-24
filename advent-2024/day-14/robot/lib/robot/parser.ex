defmodule Robot.Parser do
  @moduledoc """
  Parsing for `Robot`.
  """

  import NimbleParsec

  @opaque streamable(t) :: list(t) | Enum.t() | Enumerable.t()
  @type position() :: {non_neg_integer(), non_neg_integer()}
  @type velocity() :: {integer(), integer()}
  @type robot() :: {position(), velocity()}

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of robots
  """
  @spec parse_input_file(String.t()) :: streamable(robot())
  def parse_input_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a list of robots
  """
  @spec parse_input_string(String.t()) :: streamable(robot())
  def parse_input_string(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  defparsec :neg_integer,
    choice([
      concat(string("-"), integer(min: 1)),
      integer(min: 1),
    ])

  defparsec :robot,
    ignore(string("p="))
    |> integer(min: 1)
    |> ignore(string(","))
    |> integer(min: 1)
    |> ignore(string(" v="))
    |> parsec(:neg_integer)
    |> ignore(string(","))
    |> parsec(:neg_integer)

  @doc ~S"""
  Parse an input line containing location heights.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a robot position and velocity

  ## Examples
      iex> parse_line("p=51,19 v=-11,17\n")
      {{19, 51}, {17, -11}}
  """
  @spec parse_line(String.t()) :: robot()
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> then(fn line ->
      {:ok, [x, y | deltas], _, _, _, _} = robot(line)
      {dx, deltas} = parse_delta(deltas)
      {dy, _} = parse_delta(deltas)
      {{y, x}, {dy, dx}}
    end)
  end

  defp parse_delta([h | t]) do
    if h == "-" do
      [n | t] = t
      {-n, t}
    else
      {h, t}
    end
  end
end
