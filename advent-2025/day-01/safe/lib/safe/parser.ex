defmodule Safe.Parser do
  @moduledoc """
  Parsing for `Safe`.
  """

  @opaque streamable(t) :: list(t) | Enum.t() | Enumerable.t()

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a rotation list
  """
  @spec parse_input_file(String.t()) :: streamable([Safe.rotation()])
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

  a rotation list

  ## Examples
      iex> parse_input_string("R22\nL3456\n") |> Enum.to_list()
      [{"R22", 22}, {"L3456", -3456}]
  """
  @spec parse_input_string(String.t()) :: streamable([Safe.rotation()])
  def parse_input_string(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a rotation.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a rotation

  ## Examples
      iex> parse_line("R22\n")
      {"R22", 22}
      iex> parse_line("L321\n")
      {"L321", -321}
  """
  @spec parse_line(String.t()) :: Safe.rotation()
  def parse_line(line) do
    rot_s = String.trim_trailing(line)
    i = String.to_integer(String.slice(rot_s, 1..-1//1))
    rot_i =
      case String.slice(rot_s, 0, 1) do
        "R" -> i
        "L" -> -i
      end
    {rot_s, rot_i}
  end
end
