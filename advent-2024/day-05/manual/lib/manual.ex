defmodule Manual do
  @moduledoc """
  Documentation for `Manual`.
  """

  import Manual.Parser
  import Snow.CLI

  def correct_order?(pages, rules) do
    correct_order?(pages, [], rules)
  end

  defp correct_order?([], _seen, _rules), do: true
  defp correct_order?([page | pages], seen, rules) do
    bad_order =
      Map.get(rules, page, [])
      |> Enum.reduce(false, fn later_page, failed ->
        if Enum.find(seen, &(&1 == later_page)) do
          true
        else
          failed
        end
      end)
    if bad_order do
      false
    else
      correct_order?(pages, [page | seen], rules)
    end
  end

  @doc """
  Find the middle page of a page set.

  # TODO test even page set length (raises exception)

  ## Examples
      iex> Manual.middle_page([2, 3, 4, 1, 5])
      4
      iex> Manual.middle_page([6, 8, 7])
      8
  """
  def middle_page(pages) do
    if rem(length(pages), 2) == 1 do
      Enum.at(pages, div(length(pages), 2))
    else
      raise "even page set length"
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
    {rules, page_sets} = parse_input_file(input_path)
    page_sets
    |> Enum.filter(&(Manual.correct_order?(&1, rules)))
    |> Enum.map(&Manual.middle_page/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    {_rules, _page_sets} = parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
