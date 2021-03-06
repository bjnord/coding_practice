defmodule Geology.CLI do
  @moduledoc """
  Command-line parsing for `Geology`.
  """

  @default_parts [1, 2]

  @doc """
  Parse the command-line arguments.
  """
  def parse_args(argv) do
    switches = [strict: [parts: :string, verbose: :boolean, margin_x: :integer, margin_y: :integer]]
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
    IO.puts(:stderr, "Usage: geology [--parts=#{parts}] [--verbose] [--margin-x=<n> [--margin-y=<n>]] <input_file>")
    System.halt(64)
  end

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, opts \\ []) do
    input_file
    |> File.stream!
    |> Enum.map(&(&1))  # FIXME
    |> parse_lines(opts)
  end

  defp parse_lines(lines, opts) do
    [line1, line2 | _] = lines
    [_, d] = Regex.run(~r/depth:\s+(\d+)/, line1)
    depth = String.to_integer(d)
    [_, xc, yc] = Regex.run(~r/target:\s+(\d+),(\d+)/, line2)
    x = String.to_integer(xc)
    y = String.to_integer(yc)
    margin_x =
      if opts[:margin_x] do
        opts[:margin_x]
      else
        5
      end
    margin_y =
      if opts[:margin_y] do
        opts[:margin_y]
      else
        margin_x
      end
    Cave.new(depth, {y, x}, margin_x, margin_y)
  end
end
