defmodule Pilot.CLI do
  @moduledoc """
  Command-line parsing for `Pilot`.
  """

  @default_parts [1, 2]

  @doc """
  Parse the command-line arguments.
  """
  def parse_args(argv) do
    switches = [strict: [parts: :string, verbose: :boolean]]
    {opts, argv, unhandled} = OptionParser.parse(argv, switches)
    opts = Keyword.update(opts, :parts, @default_parts, &Pilot.CLI.part_list/1)
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
    IO.puts(:stderr, "Usage: pilot [--parts=#{parts}] [--verbose] <input_file>")
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

  @doc ~S"""
  Parse input lines.
  """
  def parse_lines(lines, _opts \\ []) do
    lines
    |> Enum.map(&Pilot.CLI.parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing direction and magnitude.

  ## Returns

  `{x, y}` position change

  ## Examples
      iex> Pilot.CLI.parse_line("forward 2")
      {2, 0}
      iex> Pilot.CLI.parse_line("up 3")
      {0, -3}
  """
  def parse_line(line) do
    Regex.run(~r/^(\w+)\s+(\d+)/, line)
    |> parse_step
  end

  defp parse_step([_, dir, mag]) when dir == "forward" do
    {String.to_integer(mag), 0}
  end
  defp parse_step([_, dir, mag]) when dir == "down" do
    {0, String.to_integer(mag)}
  end
  defp parse_step([_, dir, mag]) when dir == "up" do
    {0, -String.to_integer(mag)}
  end
end
