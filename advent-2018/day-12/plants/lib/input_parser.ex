defmodule InputParser do
  @doc ~S"""
  Parses the initial state.

  ## Returns

  Pots containing plants (MapSet)

  ## Example

      iex> InputParser.parse_initial_state("initial state: #..#.#..##......###...###\n")
      #MapSet<[0, 3, 5, 8, 9, 16, 17, 18, 22, 23, 24]>

  """
  def parse_initial_state(line) when is_binary(line) do
    line
    |> String.slice(15..-1)
    |> String.trim
    |> states_to_mapset()
  end

  defp states_to_mapset(s) when is_binary(s) do
    s
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.filter(&has_plant?/1)
    |> Enum.map(fn ({_state, x}) -> x end)
    |> Enum.into(MapSet.new())
  end

  defp has_plant?({state, _x}),
    do: has_plant?(state)
  defp has_plant?(state),
    do: state == "#"

  @doc ~S"""
  Parses a note containing a plant-spreading rule.

  ## Returns

  Tuple:
  - pattern of pots containing plants, for matching (MapSet)
  - will center pot have a plant in the next generation? (boolean)

  ## Examples

      iex> {pots, next} = InputParser.parse_note(".#.## => #\n")
      iex> pots
      #MapSet<[1, 3, 4]>
      iex> next
      true

      iex> {pots, next} = InputParser.parse_note("..#.# => .\n")
      iex> pots
      #MapSet<[2, 4]>
      iex> next
      false

  """
  def parse_note(line) when is_binary(line) do
    [rule, _, result] =
      line
      |> String.trim
      |> String.split()
    {states_to_mapset(rule), has_plant?(result)}
  end
end
