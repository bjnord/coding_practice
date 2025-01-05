defmodule Location do
  @moduledoc """
  Documentation for `Location`.
  """

  import History.CLI
  import Location.Parser

  @doc ~S"""
  Measure the distances between pairs of numbers.

  Each input list is first sorted smallest to largest, and then the
  pairwise distances are found.

  ## Examples
      iex> Location.location_pair_diff({[1, 3, 9], [5, 2, 6]})
      [1, 2, 3]
  """
  @spec location_pair_diff({[integer()], [integer()]}) :: [integer()]
  def location_pair_diff({alist, blist}) do
    [Enum.sort(alist), Enum.sort(blist)]
    |> Enum.zip()
    |> Enum.map(fn {a, b} -> abs(a - b) end)
  end

  @doc ~S"""
  Calculate a total similarity score by adding up each number in the left
  list after multiplying it by the number of times that number appears
  in the right list.

  For example, given these lists:

  ```
  3   4
  4   3
  2   5
  1   3
  3   9
  3   3
  ```

  ...here is the process of finding the similarity score:

  - The first number in the left list is 3. It appears in the right list
    three times, so the similarity score increases by `3 * 3 = 9`.
  - The second number in the left list is 4. It appears in the right list
    once, so the similarity score increases by `4 * 1 = 4`.
  - The third number in the left list is 2. It does not appear in the
    right list, so the similarity score does not increase (`2 * 0 = 0`).

  [...]
  """
  @spec similarity({[integer()], [integer()]}) :: [integer()]
  def similarity({alist, blist}) do
    bcount = occurrence_count(blist)
    Enum.map(alist, &(&1 * Map.get(bcount, &1, 0)))
  end

  defp occurrence_count(llist) do
    Enum.reduce(llist, %{}, fn n, acc ->
      Map.update(acc, n, 1, &(&1 + 1))
    end)
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
    |> location_pair_diff()
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> similarity()
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
