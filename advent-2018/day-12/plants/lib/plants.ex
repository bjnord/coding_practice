defmodule Plants do
  @moduledoc """
  Documentation for Plants.
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
    {initial_state, n_pots} = get_initial_state(argv)
    rules = get_rules(argv)
    IO.inspect(label: "Part 1 foo is")
  end

  defp get_initial_state(argv) do
    argv
    |> input_file
    |> File.stream!
    |> Enum.take(1)
    |> List.first
    |> InputParser.parse_initial_state
    |> IO.inspect(label: "initial_state, pots")
  end

  defp get_rules(argv) do
    argv
    |> input_file
    |> File.stream!
    |> Enum.drop(2)
    |> Enum.map(&InputParser.parse_note/1)
    |> Enum.reduce(%{}, fn ({pots, result}, acc) ->
      Map.put(acc, pot_scalar(pots), result)
    end)
    |> IO.inspect(label: "rules")
  end

  @doc """
  Create scalar from set of 5 pots.

  ## Parameters

  - pots: pots containing plants (MapSet)
  - start: starting position of 5-pot range (integer; default 0)

  ## Examples

  iex> Plants.pot_scalar(MapSet.new())
  0

  # 2^3 + 2^1 + 2^0
  iex> Plants.pot_scalar(MapSet.new([1, 3, 4]))
  11

  # 2^4 + 2^3 + 2^2 + 2^1 = 30
  iex> Plants.pot_scalar(MapSet.new([0, 1, 2, 3]))
  30

  iex> Plants.pot_scalar(MapSet.new([0, 1, 2, 3, 5, 8, 13]), 21)
  0

  # 2^3 + 2^0 = 9
  iex> Plants.pot_scalar(MapSet.new([0, 1, 2, 3, 5, 8, 13]), 4)
  9

  # 2^4 + 2^1 = 18
  iex> Plants.pot_scalar(MapSet.new([0, 1, 2, 3, 5, 8, 13]), 5)
  18

  # 2^3 + 2^1 = 10
  iex> Plants.pot_scalar(MapSet.new([-1, 1]), -2)
  10

  """
  def pot_scalar(pots, start \\ 0) do
    range = start..start+4
    pots
    |> Enum.filter(&(Enum.member?(range, &1)))
    |> Enum.reduce(0, fn (b, acc) ->
      acc + (:math.pow(2, (4 - (b - start))) |> round)
    end)
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
      _          -> abort('Usage: plants filename', 64)
    end
  end

  @doc """
  Hello world.

  ## Examples

      iex> Plants.hello
      :world

  """
  def hello do
    :world
  end
end
