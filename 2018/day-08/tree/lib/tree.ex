defmodule Tree do
  @moduledoc """
  Documentation for Tree.
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
    argv
    |> input_file
    |> File.read!
    |> parse_integers
    |> IO.inspect(label: "input")
    |> reduce_to_nodes
  end

  @doc """
  Parse string to list of integers.

  ## Parameters

  - str: The string

  ## Returns

  The list of integers
  """
  def parse_integers(str) do
    str
    |> String.trim
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(argv) do
    argv
    |> input_file
    |> File.read!
    |> parse_integers
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
      _          -> abort('Usage: sleigh filename', 64)
    end
  end

  @doc """
  Reduce input list to map of nodes. The input takes the form:

  ```
  n_children n_meta [child_1] [child_2] ... [child_n] meta_1 meta_2 ... meta_n
  ```

  where each `[child_x]` is a nested example of the same form.

  ## Parameters

  - input: Input values (list of integers)

  ## Returns

  Map of nodes in the form {[<children>], [<metas>]}
  """
  def reduce_to_nodes(_input) do
    {[], []}
  end
end
