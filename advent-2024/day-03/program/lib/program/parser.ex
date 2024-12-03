defmodule Program.Parser do
  @moduledoc """
  Parsing for `Program`.
  """

  @type instruction() :: {atom(), [integer()]}

  @doc ~S"""
  Parse the input file.

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
  Parse input as a block string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a list of program instructions

  ## Examples
      iex> parse_input_string("xmul(2,4)%&mul(3,7)!@^do_not_mul(5,5)+") |> Enum.to_list()
      [{:mul, [2, 4]}, {:mul, [3, 7]}, {:mul, [5, 5]}]
  """
  @spec parse_input_string(String.t()) :: [instruction()]
  def parse_input_string(input) do
    Regex.scan(~r/mul\(\d+,\d+\)/, input)
    |> Enum.map(fn matches -> parse_inst(hd(matches)) end)
  end

  @doc ~S"""
  Parse a program instruction.

  ## Parameters

  - `inst`: a program instruction string

  ## Returns

  a program instruction

  ## Examples
      iex> parse_inst("mul(13,8)")
      {:mul, [13, 8]}
      iex> parse_inst("mul(5,2)")
      {:mul, [5, 2]}
  """
  @spec parse_inst(String.t()) :: instruction()
  def parse_inst(inst) do
    numbers =
      inst
      |> String.replace("mul(", "")
      |> String.replace(")", "")
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    {:mul, numbers}
  end
end
