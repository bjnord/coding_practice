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

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&(&1))  # FIXME
    |> parse_lines()
  end

  defp parse_lines(lines) do
    [line1, line2 | _] = lines
    [_, d] = Regex.run(~r/depth:\s+(\d+)/, line1)
    depth = String.to_integer(d)
    [_, xc, yc] = Regex.run(~r/target:\s+(\d+),(\d+)/, line2)
    x = String.to_integer(xc)
    y = String.to_integer(yc)
    Cave.new(depth, {y, x})
  end
end
