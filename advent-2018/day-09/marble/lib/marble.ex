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

  - Part 1 answer is: 409832
  """
  def part1(argv) do
    {:ok, [n_players, last_marble], _, _, _, _} =
      argv
      |> input_file
      |> File.read!
      |> String.trim
      |> InputParser.input_line
    1..10_000_000
    |> Enum.reduce_while({Circle.new(), %{}, 1}, fn (move, {circle, scores, player}) ->
      {circle, score} = Circle.insert(circle)
      scores = Map.update(scores, player, score, &(&1 + score))
      case move do
        ^last_marble -> {:halt, scores}
        _            -> {:cont, {circle, scores, rem(player, n_players) + 1}}
      end
    end)
    |> Enum.max_by(fn ({_p, score}) -> score end)
    |> elem(1)
    |> IO.inspect(label: "Part 1 winning score is")
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
