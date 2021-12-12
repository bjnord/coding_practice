defmodule Submarine.CLI do
  @moduledoc """
  Command-line parsing for `Submarine`.
  """

  @default_parts [1, 2]

  @doc """
  Parse the command-line arguments.

  Returns a tuple with the input filename and an options `Keyword` list.
  """
  def parse_args(argv) do
    switches = [strict: [parts: :string, verbose: :boolean, times: :boolean]]
    {opts, argv, unhandled} = OptionParser.parse(argv, switches)
    opts = Keyword.update(opts, :parts, @default_parts, fn parts -> part_list(parts) end)
    cond do
      unhandled != [] ->
        usage()
      Enum.count(argv) == 1 ->
        {List.first(argv), opts}
      true ->
        usage()
    end
  end

  ###
  # Turn `--parts=12` argument into `[1, 2]` array.
  #
  defp part_list(parts) when is_binary(parts) do
    String.trim(parts)
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  ###
  # Emit usage.
  #
  defp usage() do
    escript = :escript.script_name()
    parts = Enum.join(@default_parts)
    IO.puts(:stderr, "Usage: #{escript} [--parts=#{parts}] [--verbose] [--times] <input-file>")
    System.halt(64)
  end
end
