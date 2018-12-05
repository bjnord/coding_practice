defmodule Alchemy do
  @moduledoc """
  Documentation for Alchemy.
  """

  defp abort(message, excode) do
    IO.puts(:stderr, message)
    System.halt(excode)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 1 answer is: ...
  """
  def part1(argv) do
  end

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(argv) do
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
      _          -> abort('Usage: alchemy filename', 64)
    end
  end

  @doc """
  Does string have reacting unit pair at the given position?

  ## Parameters

  - str: String to scan
  - pos: Position at which to scan

  ## Returns
  
  `true` if position has a reacting unit pair, otherwise `false`

  """
  def reactant_at(str, pos) do
    letters = str
              |> String.slice(pos..pos+1)
              |> String.graphemes()
    if length(letters) == 2 do
      is_reactant(letters)
    else
      false
    end
  end

  # Is this a reacting unit pair?
  # (argument must be list of exactly two)
  defp is_reactant(letters) do
    {a, b} = List.to_tuple(letters)
    (a != b) && (String.upcase(a) == String.upcase(b))
  end
end
