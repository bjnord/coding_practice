defmodule HotChocolate.CLI do
  @moduledoc """
  Command-line parsing for `HotChocolate`.
  """

  @doc """
  Parse the command-line arguments.
  """
  def parse_args(argv) do
    case OptionParser.parse(argv) do
      {[parts: parts], [input_file], _} ->
        {input_file, part_list(parts)}
      {_, [input_file], _} ->
        {input_file, [1, 2]}
      _ ->
        usage()
    end
  end

  defp part_list(parts) when is_binary(parts) do
    String.trim(parts)
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Emit usage.
  """
  def usage() do
    IO.puts(:stderr, "Usage: hot_chocolate [--parts 12] <input_file>")
    System.halt(64)
  end
end
