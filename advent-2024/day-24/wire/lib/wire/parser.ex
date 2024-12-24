defmodule Wire.Parser do
  @moduledoc """
  Parsing for `Wire`.
  """

  import NimbleParsec

  @type fixed_wire() :: integer()
  @type wire_gate() :: {String.t(), atom(), String.t()}
  @type connection_rhs() :: fixed_wire() | wire_gate()
  @type connection() :: {String.t(), connection_rhs()}
  @type diagram() :: %{String.t() => connection_rhs()}

  @doc ~S"""
  Parse an input file.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a wiring diagram
  """
  @spec parse_input_file(String.t()) :: diagram()
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

  a wiring diagram
  """
  @spec parse_input_string(String.t()) :: diagram()
  def parse_input_string(input) do
    [fixed_wires, wire_gates] =
      input
      |> String.split("\n\n", trim: true)
    wires1 =
      fixed_wires
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line_fixed/1)
    wires2 =
      wire_gates
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line_gate/1)
    wires1 ++ wires2
    |> Enum.into(%{})
  end

  defparsec :ident_char,
    choice([
      ascii_char([?a..?z]),
      ascii_char([?0..?9]),
    ])

  defparsec :ident,
    parsec(:ident_char)
    |> parsec(:ident_char)
    |> parsec(:ident_char)

  defparsec :gate,
    choice([
      string("AND"),
      string("OR"),
      string("XOR"),
    ])

  # x00: 1
  defparsec :fixed_wire,
    parsec(:ident)
    |> ignore(string(": "))
    |> ascii_char([?0..?1])

  @doc ~S"""
  Parse an input line containing a fixed wire.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a fixed wire

  ## Examples
      iex> parse_line_fixed("x00: 1\n")
      {:x00, 1}
      iex> parse_line_fixed("y02: 0\n")
      {:y02, 0}
  """
  @spec parse_line_fixed(String.t()) :: {String.t(), fixed_wire()}
  def parse_line_fixed(line) do
    {:ok, chars, _, _, _, _} = fixed_wire(line)
    ident = Enum.slice(chars, 0..2)
            |> List.to_string()
    value = Enum.at(chars, 3)
    {
      String.to_atom(ident),
      value - ?0,
    }
  end

  # x00 AND y00 -> z00
  defparsec :wire_gate,
    parsec(:ident)
    |> ignore(string(" "))
    |> parsec(:gate)
    |> ignore(string(" "))
    |> parsec(:ident)
    |> ignore(string(" -> "))
    |> parsec(:ident)

  @doc ~S"""
  Parse an input line containing a wire gate.

  Since gates are commutative, swap Y-X to be X-Y.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a gate-type wire

  ## Examples
      iex> parse_line_gate("x00 AND y00 -> z00\n")
      {:z00, {:x00, :AND, :y00}}
      iex> parse_line_gate("y02 OR x02 -> z02\n")
      {:z02, {:x02, :OR, :y02}}
  """
  @spec parse_line_gate(String.t()) :: {String.t(), wire_gate()}
  def parse_line_gate(line) do
    {:ok, tokens, _, _, _, _} = wire_gate(line)
    ident1 = Enum.slice(tokens, 0..2)
             |> List.to_string()
    gate = Enum.at(tokens, 3)
    ident2 = Enum.slice(tokens, 4..6)
             |> List.to_string()
    {ident1, ident2} =
      Enum.slice(tokens, 0..4)
      |> swap({ident1, ident2})
    ident = Enum.slice(tokens, 7..9)
            |> List.to_string()
    {
      String.to_atom(ident),
      {
        String.to_atom(ident1),
        String.to_atom(gate),
        String.to_atom(ident2),
      }
    }
  end

  defp swap([?y, _, _, _, ?x], {ident1, ident2}), do: {ident2, ident1}
  defp swap(_, {ident1, ident2}), do: {ident1, ident2}
end
