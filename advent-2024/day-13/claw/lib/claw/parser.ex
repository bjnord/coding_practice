defmodule Claw.Parser do
  @moduledoc """
  Parsing for `Claw`.
  """

  import NimbleParsec

  @opaque streamable(t) :: list(t) | Enum.t | Enumerable.t

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of claw machine configurations
  """
  @spec parse_input_file(String.t()) :: [%{}]
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

  a list of claw machine configurations
  """
  @spec parse_input_string(String.t()) :: [%{}]
  def parse_input_string(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_machine/1)
  end

  defparsec :button,
    ignore(string("Button "))
    |> ascii_char([?A..?B])
    |> ignore(string(": X+"))
    |> integer(min: 1)
    |> ignore(string(", Y+"))
    |> integer(min: 1)

  defparsec :prize,
    ignore(string("Prize: X="))
    |> integer(min: 1)
    |> ignore(string(", Y="))
    |> integer(min: 1)

  defparsec :machine,
    parsec(:button)
    |> ignore(string("\n"))
    |> parsec(:button)
    |> ignore(string("\n"))
    |> parsec(:prize)

  @doc ~S"""
  Parse input lines containing one claw machine configuration.

  ## Parameters

  - `lines`: the puzzle input lines (separated by newlines)

  ## Returns

  a claw machine configuration

  ## Examples
      iex> parse_machine("Button A: X+3, Y+4\nButton B: X+2, Y+5\nPrize: X=1717, Y=2345\n")
      %{a: {4, 3}, b: {5, 2}, prize: {2345, 1717}}
  """
  @spec parse_machine(String.t()) :: map()
  def parse_machine(lines) do
    {:ok, [?A, ax, ay, ?B, bx, by, px, py], _, _, _, _} = machine(lines)
    %{
      a: {ay, ax},
      b: {by, bx},
      prize: {py, px},
    }
  end
end
