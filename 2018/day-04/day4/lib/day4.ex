defmodule Day4 do
  @moduledoc """
  Documentation for Day4.
  """

  defp abort(message, excode) do
    IO.puts(:stderr, message)
    System.halt(excode)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)
  """
  def part1(argv) do
    argv
    |> input_file
    |> File.stream!
    |> sort_lines
    |> IO.inspect
  end

  @doc """
  Get name of input file from command-line arguments.

  ## Parameters

  - argv: Command-line arguments

  ## Returns

  Input filename (or aborts if argv invalid)
  """
  def input_file(argv) do
    case argv do
      [filename] -> filename
      _          -> abort('Usage: day4 filename', 64)
    end
  end

  @doc """
  Chronologically sort input lines of the form:

  `[1518-11-01 23:58] Guard #99 begins shift`

  ## Parameters

  - lines: List of input lines (strings)

  ## Returns

  - List of chronologically-sorted input lines (strings)

  """
  def sort_lines(lines) do
    Enum.sort(lines)
  end

  @doc """
  Extract minute from timestamp of the form:

  `[1518-11-01 23:58] …`

  ## Parameters

  - line: Input line (string)

  ## Returns

  - Minute (integer)

  """
  def minute_of(line) do
    String.slice(line, 15..16)
    |> String.to_integer
  end
end
