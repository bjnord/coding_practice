defmodule InputParser do
  @doc """
  Parses the initial state.

  ## Returns

  MapSet of pot IDs containing plants

  ## Example

  iex> InputParser.parse_initial_state("initial state: #..#.#..##......###...###\\n")
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

  @doc """
  Parses a plant-spreading note.

  ## Returns

  Tuple:
  - MapSet of pot IDs containing plants (for matching)
  - boolean: will pot have a plant in the next generation?

  ## Examples

  # FIXME these doctests won't compile; don't know why

  # iex> InputParser.parse_note(".#.## => #\\n")
  # {#MapSet<[1, 3, 4]>, true}

  # iex> InputParser.parse_note("..#.# => .\\n")
  # {#MapSet<[2, 4]>, false}

  """
  def parse_note(line) when is_binary(line) do
    [rule, _, result] =
      line
      |> String.trim
      |> String.split()
    {states_to_mapset(rule), has_plant?(result)}
  end
end
