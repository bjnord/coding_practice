defmodule Geology.CLI do
  @moduledoc """
  Command-line parsing for `Geology`.
  """

  @default_parts [1, 2]

  @doc """
  Parse the command-line arguments.
  """
  def parse_args(argv) do
    switches = [strict: [parts: :string, verbose: :boolean]]
    {opts, argv, unhandled} = OptionParser.parse(argv, switches)
    opts = Keyword.update(opts, :parts, @default_parts, &Geology.CLI.part_list/1)
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
    IO.puts(:stderr, "Usage: geology [--parts=#{parts}] [--verbose] <input_file>")
    System.halt(64)
  end
end
