defmodule Lens.Parser do
  @moduledoc """
  Parsing for `Lens`.
  """

  @doc ~S"""
  Parse the input file.

  (This produces a different result depending on the puzzle part rules.
  See "Examples" for `parse_input_string()`.)
  """
  def parse_input(input_file, opts \\ []) do
    File.read!(input_file)
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse input as a block string.

  (This produces a different result depending on the puzzle part rules.
  See "Examples".)

  ## Parameters

  - `input` - block string containing puzzle input
  - `opts` - `part` keyword (1 or 2)

  ## Examples
      iex> parse_input_string("rn=1,cm-\n", part: 1)
      ["rn=1", "cm-"]
      iex> parse_input_string("rn=1,cm-\n", part: 2)
      [{0, :install, "rn", 1}, {0, :remove,  "cm"}]
  """
  def parse_input_string(input, opts \\ []) do
    input
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(fn s -> parse_instruction(s, opts[:part]) end)
  end

  @doc ~S"""
  Parse an IV instruction.

  (This produces a different result depending on the puzzle part rules.
  See "Examples".)

  ## Parameters

  - `inst`: the instruction (string)
  - `part`: the puzzle part (1 or 2)

  ## Examples
      iex> parse_instruction("rn=1", 1)
      "rn=1"
      iex> parse_instruction("rn=1", 2)
      {0, :install, "rn", 1}
  """
  def parse_instruction(inst, part) when part == 1, do: inst
  def parse_instruction(inst, part) when part == 2 do
    [label, op, focal] =
      Regex.split(~r{[=-]}, inst, include_captures: true)
    hash = Lens.hash(label)
    case op do
      "=" ->
        {hash, :install, label, String.to_integer(focal)}
      "-" ->
        {hash, :remove, label}
      _ ->
        raise "invalid instruction #{inst}"
    end
  end
end
