defmodule HotChocolate.CLI do
  @moduledoc """
  Command-line parsing for `HotChocolate`.
  """

  @doc """
  Parse the command-line arguments.
  """
  def parse_args(argv) do
    parsed_args = OptionParser.parse(argv)
    case parsed_args do
      {_, [input_file], _}
        -> input_file
      _
        -> usage()
    end
  end

  @doc """
  Emit usage.
  """
  def usage() do
    IO.puts(:stderr, "Usage: hot_chocolate <input_file>")
    System.halt(64)
  end
end
