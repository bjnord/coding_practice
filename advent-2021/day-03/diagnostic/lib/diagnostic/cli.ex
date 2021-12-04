defmodule Diagnostic.CLI do
  @moduledoc """
  Command-line parsing for `Diagnostic`.
  """

  use Bitwise

  @default_parts [1, 2]

  @doc """
  Parse the command-line arguments.
  """
  def parse_args(argv) do
    switches = [strict: [parts: :string, verbose: :boolean]]
    {opts, argv, unhandled} = OptionParser.parse(argv, switches)
    opts = Keyword.update(opts, :parts, @default_parts, &Diagnostic.CLI.part_list/1)
    cond do
      unhandled != [] ->
        usage()
      Enum.count(argv) == 1 ->
        {List.first(argv), opts}
      true ->
        usage()
    end
  end

  def part_list(parts) when is_binary(parts) do
    String.trim(parts)
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Emit usage.
  """
  def usage() do
    parts = Enum.join(@default_parts)
    IO.puts(:stderr, "Usage: diagnostic [--parts=#{parts}] [--verbose] <input_file>")
    System.halt(64)
  end

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&Diagnostic.CLI.parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a binary number.

  Returns list of integer bit values

  ## Examples
      iex> Diagnostic.CLI.parse_line("00010\n")
      [0, 0, 0, 1, 0]
      iex> Diagnostic.CLI.parse_line("11110\n")
      [1, 1, 1, 1, 0]
  """
  def parse_line(line) do
    line
    |> String.trim_trailing
    |> String.to_charlist
    |> Enum.map(fn b -> b &&& 1 end)
  end
end
