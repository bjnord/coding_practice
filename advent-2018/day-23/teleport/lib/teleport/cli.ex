defmodule Teleport.CLI do
  @moduledoc """
  Command-line parsing for `Teleport`.
  """

  @default_parts [1, 2]

  @doc """
  Parse the command-line arguments.
  """
  def parse_args(argv) do
    switches = [strict: [parts: :string, verbose: :boolean]]
    {opts, argv, unhandled} = OptionParser.parse(argv, switches)
    opts = Keyword.update(opts, :parts, @default_parts, &Teleport.CLI.part_list/1)
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
    IO.puts(:stderr, "Usage: teleport [--parts=#{parts}] [--verbose] <input_file>")
    System.halt(64)
  end

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, opts \\ []) do
    input_file
    |> File.stream!
    |> parse_lines(opts)
  end

  def parse_lines(lines, _opts \\ []) do
    lines
    |> Enum.reduce(MapSet.new(), fn (line, bots) ->
      MapSet.put(bots, parse_line(line))
    end)
  end

  def parse_line(line) do
    [_, xc, yc, zc, rc] = Regex.run(~r/pos=<([\d-]+),([\d-]+),([\d-]+)>, r=([\d-]+)/, line)
    x = String.to_integer(xc)
    y = String.to_integer(yc)
    z = String.to_integer(zc)
    r = String.to_integer(rc)
    {{x, y, z}, r}
  end
end
