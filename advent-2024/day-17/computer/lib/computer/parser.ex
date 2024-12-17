defmodule Computer.Parser do
  @moduledoc """
  Parsing for `Computer`.
  """

  import NimbleParsec

  @type registers() :: {integer(), integer(), integer()}
  @type program() :: [integer()]

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  the computer's initial registers and program
  """
  @spec parse_input_file(String.t()) :: {registers(), program()}
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

  the computer's initial registers and program
  """
  @spec parse_input_string(String.t()) :: {registers(), program()}
  def parse_input_string(input) do
    input
    |> String.split("\n\n", trim: true)
    |> then(fn [r, p] ->
      {
        parse_registers(r),
        parse_program(p),
      }
    end)
  end

  defparsec :register,
    ignore(string("Register "))
    |> utf8_char([?A..?C])
    |> ignore(string(": "))
    |> integer(min: 1)

  @doc ~S"""
  Parse a block of initial register values.

  ## Parameters

  - `registers`: the registers string

  ## Returns

  a list of initial register values

  ## Examples
      iex> parse_registers("Register A: 5\nRegister B: 3\nRegister C: 1\n")
      {5, 3, 1}
  """
  @spec parse_registers(String.t()) :: registers()
  def parse_registers(registers) do
    registers
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      {:ok, [reg, value], _, _, _, _} = register(line)
      {reg, value}
    end)
    |> Enum.sort()
    |> Enum.map(&(elem(&1, 1)))
    |> List.to_tuple()
  end

  defparsec :program,
    ignore(string("Program: "))
    |> utf8_string([], min: 1)

  @doc ~S"""
  Parse a program.

  ## Parameters

  - `program`: the program string

  ## Returns

  the program

  ## Examples
      iex> parse_program("Program: 1,2,3,5,7\n")
      [1, 2, 3, 5, 7]
  """
  @spec parse_program(String.t()) :: program()
  def parse_program(line) do
    {:ok, [program], _, _, _, _} = program(line)
    program
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
