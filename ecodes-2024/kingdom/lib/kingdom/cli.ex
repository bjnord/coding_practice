defmodule Kingdom.CLI do
  @moduledoc """
  Command-line parsing for `Kingdom`.
  """

  @default_parts [1, 2, 3]

  @doc """
  Parse the command-line arguments.

  Returns an options `Keyword` list.
  """
  def parse_args(argv) do
    switches = [strict: [parts: :string, verbose: :boolean, times: :boolean, visualize: :boolean]]
    {opts, argv, unhandled} = OptionParser.parse(argv, switches)
    opts = Keyword.update(opts, :parts, @default_parts, fn parts -> part_list(parts) end)
    cond do
      unhandled != [] ->
        usage()
      Enum.count(argv) == 0 ->
        opts
      true ->
        usage()
    end
  end

  ###
  # Turn `--parts=123` argument into `[1, 2, 3]` array.
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
    IO.puts(:stderr, "Usage: #{escript} [--parts=#{parts}] [--verbose] [--times] [--visualize]")
    System.halt(64)
  end
end
