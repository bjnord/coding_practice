defmodule Lift do
  @moduledoc """
  Documentation for `Lift`.
  """

  import Decor.CLI
  import Lift.Parser
  require Logger

  @doc """
  Generate a map of battery positions within a bank.

  ## Examples
      iex> Lift.position_map(~c"1234")
      %{:len => 4, 1 => [0], 2 => [1], 3 => [2], 4 => [3], 5 => [], 6 => [], 7 => [], 8 => [], 9 => []}
      iex> Lift.position_map(~c"4142")
      %{:len => 4, 1 => [1], 2 => [3], 3 => [], 4 => [0, 2], 5 => [], 6 => [], 7 => [], 8 => [], 9 => []}
  """
  def position_map(bank) do
    pos_map =
      bank
      |> Enum.with_index()
      |> Enum.reduce(%{len: length(bank)}, fn {ch, i}, acc ->
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
      iex> Lift.max_joltage(~c"1234", 3)
      234
      iex> Lift.max_joltage(~c"4142", 3)
      442
  """
  def max_joltage(bank, n_batt \\ 2) do
    pos_map = position_map(bank)
    Logger.debug("start -- bank #{inspect(bank)} n_batt=#{n_batt}")
    find_max_joltage(pos_map, [{9, 0}], n_batt, pos_map[:len] - n_batt)
  end

  defp find_max_joltage(_pos_map, [{9, _} | found], 0, _) do
    # termination condition: found the highest N batteries
    Logger.debug("end -- found #{inspect(found)}")
    found
    |> Enum.reverse()
    |> Enum.reduce(0, fn {batt, _}, acc -> acc * 10 + batt end)
  end
  defp find_max_joltage(pos_map, [{0, _}, {batt, _} | found], n_batt, max_i) do
    # couldn't find any batteries to the right of the current one
    # start over and find a new Nth battery
    find_max_joltage(pos_map, [{batt - 1, 0} | found], n_batt + 1, max_i - 1)
  end
  defp find_max_joltage(pos_map, [{batt, min_i} | found], n_batt, max_i) do
    positions = Map.get(pos_map, batt)
    match_i = Enum.find(positions, fn pos -> (pos >= min_i) && (pos <= max_i) end)
    if match_i do
      # found a battery that matches the requirements
      # keep it, and start searching for the next one to the right
      find_max_joltage(pos_map, [{9, match_i + 1}, {batt, match_i} | found], n_batt - 1, max_i + 1)
    else
      # didn't find a matching battery
      # try to find the next highest battery
      find_max_joltage(pos_map, [{batt - 1, min_i} | found], n_batt, max_i)
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
    |> Enum.map(fn bank -> max_joltage(bank, 12) end)
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
