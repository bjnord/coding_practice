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

  - Part 1 answer is: 10804
  """
  def part1(argv) do
    argv
    |> input_file
    |> File.read!
    |> String.trim
    |> remove_reactants(0)
    |> String.length
    |> IO.inspect(label: "Part 1 remainder length is")
  end

  defp remove_reactants(str, pos) do
    len = String.length(str)
    eos = pos >= len
    has_r = reactant_at(String.graphemes(str), pos)
    #IO.inspect({eos, has_r, pos, len, str})
    progress = rem(len, 100)
    if (progress == 0) || (progress == 1) do
      IO.inspect(len, label: "String length")
    end
    case {eos, has_r, pos} do
      {true, _, _}      -> str
      {false, true, 0}  -> remove_reactants(remove_pair(str, pos), 0)
      {false, true, _}  -> remove_reactants(remove_pair(str, pos), pos-1)
      {false, false, _} -> remove_reactants(str, pos+1)
    end
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

  - letters: List of letters to scan
  - pos: Position at which to scan

  ## Returns

  `true` if position has a reacting unit pair, otherwise `false`

  """
  def reactant_at(letters, pos) do
    pair = Enum.slice(letters, pos, 2)
    if length(pair) == 2 do
      is_reactant(pair)
    else
      false
    end
  end

  # Is this a reacting unit pair?
  # (argument must be list of exactly two letters)
  defp is_reactant(letters) do
    {a, b} = List.to_tuple(letters)
    (a != b) && (String.upcase(a) == String.upcase(b))
  end

  @doc """
  Remove unit pair from string at the given position.

  ## Parameters

  - str: String from which to remove
  - pos: Position at which to remove

  ## Returns

  String with unit pair removed

  """
  def remove_pair(str, pos) do
    if pos == 0 do
      String.slice(str, pos+2..-1)
    else
      String.slice(str, 0..pos-1) <> String.slice(str, pos+2..-1)
    end
  end
end
