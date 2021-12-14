defmodule Polymer do
  @moduledoc """
  Documentation for Polymer.
  """

  import Polymer.Parser
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    # "Apply 10 steps of pair insertion to the polymer template and find
    # the most and least common elements in the result. What do you get
    # if you take the quantity of the most common element and subtract the
    # quantity of the least common element?"
    {template, rules} =
      File.read!(input_file)
      |> parse_input_string()
    polymer =
      1..10
      |> Enum.reduce(template, fn (_n, polymer) ->
        Polymer.step(polymer, rules)
      end)
    min_max = Polymer.min_max(polymer)
    (elem(min_max, 1) - elem(min_max, 0))
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Perform one step of polymer insertion.

  ## Examples
      iex> rules = %{{?A, ?A} => ?B}
      iex> Polymer.step("AAA", rules)
      "ABABA"
  """
  def step(polymer, rules) do
    elements =
      polymer
      |> String.to_charlist()
      #|> IO.inspect(label: "elements")
    insertions =
      elements
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&List.to_tuple/1)
      #|> IO.inspect(label: "windows")
      |> Enum.map(fn k -> rules[k] end)
      #|> IO.inspect(label: "insertions")
    new_elements =
      [elements, insertions]
      |> Enum.zip()
      |> Enum.flat_map(&Tuple.to_list/1)
      #|> IO.inspect(label: "zipped elements")
    # FIXME OPTIMIZE this is really inefficient
    new_elements ++ [List.last(elements)]
    |> to_string()
    #|> IO.inspect(label: "new polymer")
  end

  @doc """
  Find the minimum and maximum number of element occurrences in the given
  `polymer`.

  ## Examples
      iex> Polymer.min_max("AABACABA")
      {1, 5}
  """
  def min_max(polymer) do
    frequencies =
      polymer
      |> String.to_charlist()
      # TODO Elixir v1.10 has `Enum.frequencies()`
      |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    min = Enum.min(Map.values(frequencies))
    max = Enum.max(Map.values(frequencies))
    {min, max}
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> parse_input_string()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
