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

  - Part 1 answer is: 1987
  """
  def part1(argv) do
    {pots, _n_pots} = get_initial_state(argv)
    rules = get_rules(argv)
    1..20
    |> Enum.reduce(pots, fn (_n, pots) ->
      Plants.next_generation(pots, rules)
    end)
    |> Enum.sum
    |> IO.inspect(label: "Part 1 sum is")
  end

  defp get_initial_state(argv) do
    argv
    |> input_file
    |> File.stream!
    |> Enum.take(1)
    |> List.first
    |> InputParser.parse_initial_state
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
  end

  @doc """
  Compute range of pots to consider for next generation.

  We need to look 4 pots further than the leftmost and rightmost
  pots that have a plant. 5 pots further will always be "....."
  and the rules always say this pattern will not produce a plant.

  ## Examples

  iex> Plants.pot_range(MapSet.new([1, 3, 4]))
  -3..8

  iex> Plants.pot_range(MapSet.new([0, 3, 5, 7, 9, 11]))
  -4..15

  """
  def pot_range(pots) do
    {min, max} = Enum.min_max(pots)
    min-4..max+4
  end

  @doc """
  Compute the next state generation.

  ## Parameters

  - pots: pots containing plants (MapSet)
  - rules: rules for generating next pot state (Map)

  ## Returns

  New state of pots containing plants (MapSet)

  """
  def next_generation(pots, rules) do
    pot_range(pots)
    |> Enum.reduce(MapSet.new(), fn (pot_no, acc) ->
      if rules[pot_scalar(pots, pot_no-2)] do
        MapSet.put(acc, pot_no)
      else
        acc
      end
    end)
  end

  @doc """
  Render state of pots.
  (Only used for testing.)

  ## Examples

  iex> Plants.render_state(MapSet.new([1, 3, 4]), 0..4)
  ".#.##"

  iex> Plants.render_state(MapSet.new([1, 3, 5, 7, 9, 11]), -3..16)
  "....#.#.#.#.#.#....."

  """
  def render_state(pots, range) do
    Enum.reduce(range, [], fn (i, acc) ->
      case MapSet.member?(pots, i) do
        true ->
          [?# | acc]
        _ ->
          [?. | acc]
      end
    end)
    |> Enum.reverse
    |> to_string
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
end
