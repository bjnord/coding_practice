defmodule Combat.Arena do
  # TODO change comments to correct form (parameterized, etc.)
  @type position() :: tuple()  # {y :: non_neg_integer(), x :: non_neg_integer()}
  @type square() :: atom()  # :rock | :floor | :combatant
  @type grid() :: %{required(position()) => square()}
  @type team() :: :elf | :goblin  # {y_x :: position(), team(), power :: non_neg_integer(), hp :: integer()}
  @type combatant() :: tuple()  # {y_x :: position(), team :: atom(), power :: non_neg_integer(), hp :: integer()}
  @type roster() :: MapSet.t()  # of combatant()
  # FIXME In Elixr, for module Foo the main type for Foo should be named Foo.t
  @type arena() :: {grid(), roster()}

  @doc ~S"""
  Parses a line from the initial state, adding its data to accumulators.

  ## Example

      iex> {grid, roster} = Combat.Arena.parse_line({%{}, MapSet.new()}, "  #GE#.E..  \n", 42)
      iex> grid
      %{
        {42, 2} => :rock,
        {42, 3} => :combatant,
        {42, 4} => :combatant,
        {42, 5} => :rock,
        {42, 6} => :floor,
        {42, 7} => :combatant,
        {42, 8} => :floor,
        {42, 9} => :floor,
      }
      iex> roster
      #MapSet<[{{42, 3}, :goblin, 3, 200}, {{42, 4}, :elf, 3, 200}, {{42, 7}, :elf, 3, 200}]>
  """
  @spec parse_line(arena(), String.t(), non_neg_integer()) :: arena()
  def parse_line({grid, roster}, line, y) when is_binary(line) do
    line
    |> String.trim_trailing
    |> String.graphemes
    |> Enum.with_index
    |> Enum.reduce({grid, roster}, fn ({square, x}, {grid_a, roster_a}) ->
      case square_type(square) do
        {:square, kind} ->
          {
            Map.put(grid_a, {y, x}, kind),
            roster_a
          }
        {:combatant, team} ->
          {
            Map.put(grid_a, {y, x}, :combatant),
            MapSet.put(roster_a, {{y, x}, team, 3, 200})
          }
        {:void} ->
          {grid_a, roster_a}
      end
    end)
  end

  defp square_type(square) do
    case square do
      "#" -> {:square, :rock}
      "." -> {:square, :floor}
      "E" -> {:combatant, :elf}
      "G" -> {:combatant, :goblin}
      " " -> {:void}
    end
  end

#  @spec occupiable?(arena(), position()) :: boolean()
#  defp occupiable?({grid, roster}, {y, x}),
#    do: occupiable?(grid, {y, x})
#
#  @spec occupiable?(grid(), position()) :: boolean()
#  defp occupiable?(grid, {y, x}) do
#    case grid[{y, x}] do
#      :rock -> false
#      nil -> false
#      _ -> true
#    end
#  end

  @doc ~S"""
  Return the opposing team.

  ## Example

      iex> Combat.Arena.opponent(:elf)
      :goblin

      iex> Combat.Arena.opponent(:goblin)
      :elf
  """
  @spec opponent(team()) :: team()
  def opponent(:elf), do: :goblin
  def opponent(:goblin), do: :elf

  @doc ~S"""
  Find combatants for the given team.

  ## Example

      iex> arena = {%{}, MapSet.new([
      ...>   {{42, 3}, :elf, 3, 200},
      ...>   {{42, 4}, :goblin, 3, 2},
      ...>   {{42, 7}, :elf, 3, 200},
      ...> ])}
      iex> Combat.Arena.find_combatants(arena, :goblin)
      [{{42, 4}, :goblin, 3, 2}]

      iex> arena = {%{}, MapSet.new([
      ...>   {{42, 3}, :elf, 3, 200},
      ...>   {{42, 7}, :elf, 3, 200},
      ...> ])}
      iex> Combat.Arena.find_combatants(arena, :goblin)
      []
  """
  @spec find_combatants(arena(), team()) :: boolean()
  def find_combatants({_grid, roster}, team) do
    Enum.filter(roster, fn ({_pos, c_team, _pw, _hp}) -> c_team == team end)
  end

  @doc ~S"""
  Execute a round of combat.

  ## Returns

  Tuple:
  - updated arena
  - is the battle over? (boolean)

  ## Example

      iex> arena = {%{
      ...>     {0, 0} => :floor,
      ...>     {0, 1} => :combatant,
      ...>     {1, 0} => :combatant,
      ...>     {1, 1} => :floor,
      ...>   }, MapSet.new([
      ...>     {{0, 1}, :goblin, 3, 2},
      ...>     {{1, 0}, :elf, 3, 200},
      ...>   ])
      ...> }
      iex> Combat.Arena.fight(arena) |> elem(1)
      false
  """
  @spec fight(arena()) :: {arena(), boolean()}
  def fight({grid, roster}) do
    Enum.sort(roster, &(elem(&1, 0) <= elem(&2, 0)))
    |> Enum.reduce_while({{grid, roster}, false}, fn ({pos, team, pw, hp}, {{grid_a, roster_a}, _done}) ->
      IO.inspect({pos, team, pw, hp}, label: "next combatant")
      enemies = find_combatants({grid_a, roster_a}, opponent(team))
      if enemies != [] do
        # TODO inspect, move, attack, etc.
        {:cont, {{grid_a, roster_a}, false}}
      else
        {:halt, {{grid_a, roster_a}, true}}
      end
    end)
  end
end
