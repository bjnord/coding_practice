defmodule Bingo.CLI do
  @moduledoc """
  Command-line parsing for `Bingo`.
  """

  @default_parts [1, 2]

  @doc """
  Parse the command-line arguments.
  """
  def parse_args(argv) do
    switches = [strict: [parts: :string, verbose: :boolean]]
    {opts, argv, unhandled} = OptionParser.parse(argv, switches)
    opts = Keyword.update(opts, :parts, @default_parts, &Bingo.CLI.part_list/1)
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
    IO.puts(:stderr, "Usage: bingo [--parts=#{parts}] [--verbose] <input_file>")
    System.halt(64)
  end

  @doc ~S"""
  Parse the input file.

  Returns `{balls, boards}` where the former is a list, and the latter is a list of lists.
  """
  def parse_input(input, opts \\ []) do
    [ball_tok | board_tok] = input
                             |> String.split
    balls = ball_tok
            |> String.split(",")
            |> Enum.map(&String.to_integer/1)
    boards = board_tok
             |> Enum.map(&String.to_integer/1)
             |> Enum.chunk_every(25)
    {balls, boards}
  end
end
