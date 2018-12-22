defmodule Machine.CLI do
  @moduledoc """
  Command-line parsing for `Machine`.
  """

  @default_parts [1, 2]

  @doc """
  Parse the command-line arguments.
  """
  def parse_args(argv) do
    switches = [strict: [
      parts: :string,
      show_reg: :boolean,
      numeric: :string,
      disassemble: :boolean,
      decompile: :boolean,
      initial: :string,
      limit: :integer,
    ]]
    {opts, argv, unhandled} = OptionParser.parse(argv, switches)
    opts = Keyword.update(opts, :parts, @default_parts, &Machine.CLI.part_list/1)
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
    IO.puts(:stderr, "Usage: machine [--parts=#{parts}] [--show-reg] [--numeric=<hex|dec|oct>] [--disassemble] [--decompile] [--initial=<r0-value>] [--limit=<n>] <input_file>")
    System.halt(64)
  end

  @doc """
  Parse "initial R0" CLI value (hex/dec/oct).
  """
  def parse_initial(i) do
    cond do
      i == nil ->
        0
      String.slice(i, 0..1) == "0x" ->
        String.to_integer(String.slice(i, 2..-1), 16)
      String.slice(i, 0..1) == "0o" ->
        String.to_integer(String.slice(i, 2..-1), 8)
      true ->
        String.to_integer(i)
    end
  end
end
