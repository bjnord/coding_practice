defmodule Marble do
  @moduledoc """
  Documentation for Marble.
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
    {:ok, [n_players, last_points], _, _, _, _} =
      argv
      |> input_file
      |> File.read!
      |> String.trim
      |> InputParser.input_line
    IO.inspect(0, label: "Part 1 winning score is")
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
    |> IO.inspect(label: "Part 2 foo is")
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
      _          -> abort('Usage: marble filename', 64)
    end
  end

  @doc """
  Hello world.

  ## Examples

      iex> Marble.hello
      :world

  """
  def hello do
    :world
  end
end
