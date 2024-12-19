defmodule Onsen.Parser do
  @moduledoc """
  Parsing for `Onsen`.
  """

  @type towel_pattern() :: %{char() => bool() | towel_pattern()}
  @type towel() :: [char()]

  @type towel2_pattern() :: %MapSet{}
  @type towel2() :: String.t()

  @doc ~S"""
  Parse an input file.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a towel configuration
  """
  @spec parse_input_file(String.t()) :: {towel_pattern(), [towel()]}
  def parse_input_file(path) do
    path
    |> File.read!()
    |> parse_input_string()
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a towel configuration
  """
  @spec parse_input_string(String.t()) :: {towel_pattern(), [towel()]}
  def parse_input_string(input) do
    input
    |> String.split("\n\n", trim: true)
    |> then(fn [towel_patterns, towels] ->
      {
        parse_towel_patterns(towel_patterns),
        parse_towels(towels),
      }
    end)
  end

  @doc ~S"""
  Parse an input string containing a list of towel patterns.

  ## Parameters

  - `patterns`: the puzzle input towel patterns

  ## Returns

  a towel pattern (map tree)

  ## Examples
      iex> parse_towel_patterns("rw")
      %{?r => %{?w => %{?. => true}}}
      iex> parse_towel_patterns("rw, rgub")
      %{?r => %{?w => %{?. => true}, ?g => %{?u => %{?b => %{?. => true}}}}}
  """
  @spec parse_towel_patterns(String.t()) :: towel_pattern()
  def parse_towel_patterns(patterns) do
    patterns
    |> String.split(", ")
    |> Enum.reduce(%{}, fn pattern, acc ->
      parse_towel_pattern(String.to_charlist(pattern), acc)
    end)
  end

  defp parse_towel_pattern([], acc) do
    Map.put(acc, ?., true)
  end
  defp parse_towel_pattern([color | rem_pattern], acc) do
    subtree = parse_towel_pattern(rem_pattern, %{})
    Map.update(acc, color, subtree, fn v ->
      parse_towel_pattern(rem_pattern, v)
    end)
  end

  @doc ~S"""
  Parse an input string containing a towel list.

  ## Parameters

  - `towels`: the puzzle input towels

  ## Returns

  a list of towels

  ## Examples
      iex> parse_towels("rgubw\nuwub\n")
      [[?r, ?g, ?u, ?b, ?w], [?u, ?w, ?u, ?b]]
  """
  @spec parse_towels(String.t()) :: [towel()]
  def parse_towels(towels) do
    towels
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_towel/1)
  end

  @spec parse_towel(String.t()) :: towel()
  defp parse_towel(towel) do
    towel
    |> String.to_charlist()
  end

  @doc ~S"""
  Parse an input file (part 2).

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a towel configuration (part 2)
  """
  @spec parse2_input_file(String.t()) :: {towel2_pattern(), [towel2()]}
  def parse2_input_file(path) do
    path
    |> File.read!()
    |> parse2_input_string()
  end

  @doc ~S"""
  Parse an input string (part 2).

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a towel configuration (part 2)
  """
  @spec parse2_input_string(String.t()) :: {towel2_pattern(), [towel2()]}
  def parse2_input_string(input) do
    input
    |> String.split("\n\n", trim: true)
    |> then(fn [towel_patterns, towels] ->
      {
        parse2_towel_patterns(towel_patterns),
        parse2_towels(towels),
      }
    end)
  end

  @doc ~S"""
  Parse an input string containing a list of towel patterns (part 2).

  ## Parameters

  - `patterns`: the puzzle input towel patterns

  ## Returns

  a map set of towel patterns

  ## Examples
      iex> parse2_towel_patterns("rw, rgub")
      MapSet.new(["rw", "rgub"])
  """
  @spec parse2_towel_patterns(String.t()) :: towel2_pattern()
  def parse2_towel_patterns(patterns) do
    patterns
    |> String.split(", ")
    |> Enum.into(%MapSet{})
  end

  @doc ~S"""
  Parse an input string containing a towel list.

  ## Parameters

  - `towels`: the puzzle input towels

  ## Returns

  a list of towels

  ## Examples
      iex> parse2_towels("rgubw\nuwub\n")
      ["rgubw", "uwub"]
  """
  @spec parse2_towels(String.t()) :: [towel2()]
  def parse2_towels(towels) do
    towels
    |> String.split("\n", trim: true)
  end
end
