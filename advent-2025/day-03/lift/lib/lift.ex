defmodule Lift do
  @moduledoc """
  Documentation for `Lift`.
  """

  import Lift.Parser
  import History.CLI

  @doc """
  Generate a map of battery positions within a bank.

  ## Examples
      iex> Lift.position_map(~c"1234")
      %{1 => [0], 2 => [1], 3 => [2], 4 => [3], 5 => [], 6 => [], 7 => [], 8 => [], 9 => []}
      iex> Lift.position_map(~c"4142")
      %{1 => [1], 2 => [3], 3 => [], 4 => [0, 2], 5 => [], 6 => [], 7 => [], 8 => [], 9 => []}
  """
  def position_map(bank) do
    pos_map =
      bank
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {ch, i}, acc ->
        Map.update(acc, ch - ?0, [i], fn list -> [i | list] end)
      end)
    1..9
    |> Enum.reduce(pos_map, fn batt, acc ->
      Map.update(acc, batt, [], fn list -> Enum.reverse(list) end)
    end)
  end

  @doc """
  Compute the maximum joltage of a battery bank.

  ## Examples
      iex> Lift.max_joltage(~c"1234")
      34
      iex> Lift.max_joltage(~c"4142")
      44
  """
  def max_joltage(bank) do
    pos_map = position_map(bank)
    find_max_joltage(pos_map, [{9, 0}])
  end

  defp find_max_joltage(_pos_map, [{9, _}, {batt_b, _}, {batt_a, _}]) do
    # termination condition: found the highest two batteries
    batt_a * 10 + batt_b
  end
  defp find_max_joltage(pos_map, [{0, _}, {batt, _}]) do
    # couldn't find any batteries to the right of the first one
    # start over and find a new first battery
    find_max_joltage(pos_map, [{batt - 1, 0}])
  end
  defp find_max_joltage(pos_map, [{batt, min_i} | found]) do
    positions = Map.get(pos_map, batt)
    match_i = Enum.find(positions, fn pos -> pos >= min_i end)
    if match_i do
      # found a battery that matches the requirements
      # keep it, and start searching for the next one to the right
      find_max_joltage(pos_map, [{9, match_i + 1}, {batt, match_i} | found])
    else
      # didn't find a matching battery
      # try the next highest battery
      find_max_joltage(pos_map, [{batt - 1, min_i} | found])
    end
  end

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Enum.map(&max_joltage/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
