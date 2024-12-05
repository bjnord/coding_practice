defmodule Program.Parser do
  @moduledoc """
  Parsing for `Program`.
  """

  @type instruction() :: {atom(), [integer()]}

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of program instructions
  """
  @spec parse_input_file(String.t()) :: [instruction()]
  def parse_input_file(path) do
    path
    |> File.read!()
    |> parse_input_string()
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a list of program instructions

  ## Examples
      iex> parse_input_string("xdo()mul(2,4)%&mul(3,7)!@^don't()_mul(5,5)+") |> Enum.to_list()
      [{:do, []}, {:mul, [2, 4]}, {:mul, [3, 7]}, {:"don't", []}, {:mul, [5, 5]}]
  """
  @spec parse_input_string(String.t()) :: [instruction()]
  def parse_input_string(input) do
    Regex.scan(~r/mul\(\d+,\d+\)|do\(\)|don't\(\)/, input)
    |> Enum.map(fn matches -> parse_inst(hd(matches)) end)
  end

  @doc ~S"""
  Parse a program instruction string.

  ## Parameters

  - `inst`: the program instruction string

  ## Returns

  a program instruction

  ## Examples
      iex> parse_inst("mul(13,8)")
      {:mul, [13, 8]}
      iex> parse_inst("do()")
      {:do, []}
      iex> parse_inst("don't()")
      {:"don't", []}
  """
  @spec parse_inst(String.t()) :: instruction()
  def parse_inst(inst) do
    [op | opands] =
      inst
      |> String.replace("()", "")
      |> String.replace("(", ",")
      |> String.replace(")", "")
      |> String.split(",")
    {
      String.to_atom(op),
      Enum.map(opands, &String.to_integer/1),
    }
  end
end
