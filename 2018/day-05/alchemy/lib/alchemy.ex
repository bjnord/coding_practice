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
    |> String.graphemes
    |> remove_reactants
    |> length
    |> IO.inspect(label: "Part 1 remainder length is")
  end

  # Tail-recursive function to remove all reactants
  #   (this is more deeply-nested than I'd like, but I want to avoid
  #   e.g. computing the full length of the list on every call;
  #   splitting the head from a list is always cheap)
  defp remove_reactants(letters) do
    [first | tail] = letters
    case tail do
      [] ->
        # called w/only one letter; return it to parent
        [first]
      _  ->
        [second | tail2] = tail
        case tail2 do
          [] ->
             # called w/only two letters:
             if reactant?(first, second) do
               # toss them if reactant
               []
             else
               # return them to parent if not
               [first, second]
             end
          _  ->
             # called w/three or more letters: tail recursion
             new_tail = remove_reactants(tail)
             case new_tail do
               [] ->
                 # only one letter remains; return it to parent
                 [first]
               _  ->
                 # two or more letters remain:
                 [second | new_tail2] = new_tail
                 if reactant?(first, second) do
                   # toss first two letters if reactant
                   new_tail2
                 else
                   # return all to parent if not
                   [first | new_tail]
                 end
             end
        end
    end
  end

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 answer is: 6650
  """
  def part2(argv) do
    input = argv
    |> input_file
    |> File.read!
    |> String.trim
    Enum.map(?a..?z, fn (rm_cp) ->
      len = remove_unit_type(input, <<rm_cp::utf8>>)
      |> String.graphemes
      |> remove_reactants
      |> length
      {rm_cp, len}
    end)
    |> Enum.reduce({nil, 999_999_999}, fn ({cp, count}, {min_cp, min_count}) ->
      if count < min_count do
        {cp, count}
      else
        {min_cp, min_count}
      end
    end)
    |> Kernel.elem(1)
    |> IO.inspect(label: "Part 2 shortest polymer is")
  end

  # Remove all occurrences of letter (case-insensitive) from string
  defp remove_unit_type(str, letter) do
    Regex.replace(~r/#{letter}/i, str, "")
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
  Are these two letters a reacting unit pair?

  ## Parameters

  - a: First letter
  - b: Second letter

  ## Returns

  `true` if letters are a reacting unit pair, otherwise `false`

  """
  def reactant?(a, b) do
    (a != b) && (String.upcase(a) == String.upcase(b))
  end
end
