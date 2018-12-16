defmodule Combat.Arena do
  # TODO change comments to correct form (parameterized, etc.)
  @type position() :: tuple()  # {y :: non_neg_integer(), x :: non_neg_integer()}
  @type square() :: atom()  # :rock | :floor | :combatant
  @type grid() :: %{required(position()) => square()}
  @type team() :: :elf | :goblin  # {y_x :: position(), team(), power :: non_neg_integer(), hp :: integer()}
  @type combatant() :: tuple()  # {y_x :: position(), team :: atom(), power :: non_neg_integer(), hp :: integer()}
  @type candidate() :: {position(), [combatant()]}
  @type roster() :: MapSet.t()  # of combatant()
  # FIXME In Elixir, for module Foo the main type for Foo should be named Foo.t
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
  Find combatants for a team.

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

  ## Parameters

  - arena: Current arena state
  - style: Combat model

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
      iex> Combat.Arena.fight(arena, :pacifist) |> elem(1)
      false

      iex> arena = {%{
      ...>     {0, 0} => :combatant,  {0, 1} => :floor,  {0, 2} => :floor,
      ...>     {1, 0} => :rock,       {1, 1} => :floor,  {1, 2} => :floor,
      ...>     {2, 0} => :floor,      {2, 1} => :rock,   {2, 2} => :combatant,
      ...>   }, MapSet.new([
      ...>     {{0, 0}, :elf, 3, 200},
      ...>     {{2, 2}, :goblin, 3, 2},
      ...>   ])
      ...> }
      iex> Combat.Arena.fight(arena, :pacifist) |> elem(0)
      {%{
          {0, 0} => :floor,  {0, 1} => :combatant,  {0, 2} => :floor,
          {1, 0} => :rock,   {1, 1} => :floor,      {1, 2} => :combatant,
          {2, 0} => :floor,  {2, 1} => :rock,       {2, 2} => :floor,
        }, MapSet.new([
          {{0, 1}, :elf, 3, 200},
          {{1, 2}, :goblin, 3, 2},
        ])
      }
  """
  @spec fight(arena(), atom()) :: {arena(), boolean()}
  def fight({grid, roster}, style) do
    fighters =  # take turns in "reading order":
      Enum.sort_by(roster, &(elem(&1, 0)))
    # FIXME there's got to be a better way to iterate with 2 conditions
    #       (end of list or out of opponents)
    1..1_000_000 |>
    Enum.reduce_while({{grid, roster}, fighters}, fn (_c, {{grid_a, roster_a}, f_left}) ->
      [{pos, team, pw, hp} | f_left] = f_left
      opponents = find_combatants({grid_a, roster_a}, opponent(team))
      if opponents != [] do
        {grid_a, roster_a} = fight_in_style({grid_a, roster_a}, {pos, team, pw, hp}, opponents, style)
        if f_left != [] do
          {:cont, {{grid_a, roster_a}, f_left}}
        else
          {:halt, {{grid_a, roster_a}, false}}
        end
      else
        {:halt, {{grid_a, roster_a}, true}}
      end
    end)
    #|> IO.inspect(label: "ding ding ding")
  end

  # fight_in_style(): one fighter takes their turn
  @spec fight_in_style(arena(), combatant(), [combatant()], atom()) :: arena()

  defp fight_in_style({grid, roster}, fighter, opponents, :pacifist) do
    #IO.inspect(fighter, label: "next fighter (pacifist)")
    if opponents_near?({grid, roster}, fighter) do
      {grid, roster}  # no need to move
    else
      candidate = next_position({grid, roster}, fighter, opponents)
      next_step = next_step_toward({grid, roster}, fighter, candidate)
      if next_step == nil do
        {grid, roster}
      else
        move({grid, roster}, fighter, next_step)
        |> elem(0)
      end
    end
  end

  @doc ~S"""
  Find the position a combatant should be moving toward.

  If a position is returned, it will always be reachable (not blocked).

  ## Parameters

  - arena: The current arena
  - mover: The combatant who will be moving
  - opponents: The roster of _only_ the opponents

  ## Returns

  Candidate position to move toward (includes surrounding opponent list),
  or `nil` if no such position exists

  ## Examples

  # In range: [
  #   {{0, 0}, [{{0, 1}, :goblin, 3, 20}]},
  #   {{0, 2}, [{{0, 1}, :goblin, 3, 20}, {{1, 2}, :goblin, 3, 2}]},
  #   {{1, 1}, [{{0, 1}, :goblin, 3, 20}, {{1, 2}, :goblin, 3, 2}]},
  #   {{2, 2}, [{{1, 2}, :goblin, 3, 2}]}
  # ]

  # Reachable: [
  #   {{0, 0}, [{{0, 1}, :goblin, 3, 20}]},
  #   {{1, 1}, [{{0, 1}, :goblin, 3, 20}, {{1, 2}, :goblin, 3, 2}]},
  # ]

  # Nearest: [
  #   {{0, 0}, [{{0, 1}, :goblin, 3, 20}]},
  #   {{1, 1}, [{{0, 1}, :goblin, 3, 20}, {{1, 2}, :goblin, 3, 2}]},
  # ]

  # Chosen: {{0, 0}, [{{0, 1}, :goblin, 3, 20}]},

      iex> arena = {%{
      ...>     {0, 0} => :floor,     {0, 1} => :combatant, {0, 2} => :floor,
      ...>     {1, 0} => :floor,     {1, 1} => :floor,     {1, 2} => :combatant,
      ...>     {2, 0} => :combatant, {2, 1} => :rock,      {2, 2} => :floor,
      ...>   }, MapSet.new([
      ...>     {{0, 1}, :goblin, 3, 20},
      ...>     {{1, 2}, :goblin, 3, 2},
      ...>     {{2, 0}, :elf, 3, 200},
      ...>   ])
      ...> }
      iex> mover = {{2, 0}, :elf, 3, 200}
      iex> opponents = Combat.Arena.find_combatants(arena, :goblin)
      iex> Combat.Arena.next_position(arena, mover, opponents) |> elem(0)
      {0, 0}

      iex> arena = {%{
      ...>     {0, 0} => :rock,
      ...>     {0, 1} => :combatant,
      ...>     {1, 0} => :combatant,
      ...>     {1, 1} => :rock,
      ...>   }, MapSet.new([
      ...>     {{0, 1}, :goblin, 3, 2},
      ...>     {{1, 0}, :elf, 3, 200},
      ...>   ])
      ...> }
      iex> mover = {{1, 0}, :elf, 3, 200}
      iex> opponents = Combat.Arena.find_combatants(arena, :goblin)
      iex> Combat.Arena.next_position(arena, mover, opponents)
      nil
  """
  @spec next_position(arena(), combatant(), roster()) :: candidate()
  def next_position({grid, roster}, mover, opponents) do
    #IO.inspect(mover, label: "Mover")
    candidates_in_range({grid, roster}, mover, opponents)
    #|> IO.inspect(label: "In range")
    |> reachable_candidates({grid, roster}, mover, opponents)
    #|> IO.inspect(label: "Reachable")
    |> nearest_candidates({grid, roster}, mover, opponents)
    #|> IO.inspect(label: "Nearest")
    # choose first position in "reading order":
    |> min_by_or_nil(fn (candidate) -> elem(candidate, 0) end)
    #|> IO.inspect(label: "Chosen")
  end

  ###
  # Thinking ahead: What if the algorithm changes to find based on
  # attributes of mover or opponent(s)? Thus we pass them along though
  # we don't use them (yet). (But see TODO below.)
  ###

  @spec candidates_in_range(arena(), combatant(), roster()) :: [candidate()]
  defp candidates_in_range({grid, _roster}, _mover, opponents) do
    opponents
    #|> IO.inspect(label: "opponents")
    |> Enum.map(fn (opponent) -> floor_squares_around(grid, opponent) end)
    |> List.flatten
    #|> IO.inspect(label: "all candidates")
    # FIXME merge all opponents to single list as 2nd elem
    |> Enum.uniq_by(fn ({pos, _opponent}) -> pos end)
    |> Enum.map(fn ({pos, opponent}) -> {pos, [opponent]} end)
    #|> IO.inspect(label: "floor candidates")
  end

  @spec floor_squares_around(grid(), combatant()) :: [candidate()]
  defp floor_squares_around(grid, combatant) do
    {{y, x}, _team, _pw, _hp} = combatant
    [  # in "reading order":
      {{y-1, x}, combatant},
      {{y, x-1}, combatant},
      {{y, x+1}, combatant},
      {{y+1, x}, combatant},
    ]
    |> Enum.filter(fn ({pos, _combatant}) -> grid[pos] == :floor end)
  end

  @spec reachable_candidates([candidate()], arena(), combatant(), roster()) :: [candidate()]
  defp reachable_candidates(candidates, {_grid, _roster}, _mover, _opponents) do
    candidates  # FIXME
  end

  @spec nearest_candidates([candidate()], arena(), combatant(), roster()) :: [candidate()]
  defp nearest_candidates(candidates, {_grid, _roster}, mover, _opponents) do
    multi_min_by(candidates, fn ({pos, _opponents}) -> manhattan(elem(mover, 0), pos) end)
  end

  # NOTE ripped off from day 6 puzzle, but with x and y flipped
  @doc """
  Compute the Manhattan distance between two points.

  "Take the sum of the absolute values of the differences of the coordinates.
  For example, if x=(a,b) and y=(c,d), the Manhattan distance between x and y is |a−c|+|b−d|."
  <https://math.stackexchange.com/a/139604>

  ## Examples

  iex> Combat.Arena.manhattan({2, 2}, {1, 1})
  2

  iex> Combat.Arena.manhattan({6, 3}, {5, 7})
  5

  """
  def manhattan({y1, x1}, {y2, x2}) do
    abs(y1 - y2) + abs(x1 - x2)
  end

  # TODO surprised this isn't a standard Enum function
  defp multi_min_by(enum, func) do
    Enum.reduce(enum, {1_000_000, []}, fn (el, {min_v, min_list}) ->
      v = func.(el)
      cond do
        v > min_v ->
          {min_v, min_list}
        v == min_v ->
          {min_v, [el | min_list]}
        v < min_v ->
          {v, [el]}
      end
    end)
    |> elem(1)
    |> Enum.reverse
  end

  # TODO seems I'm creating my own little Enum-extensions library
  def min_by_or_nil(enum, func) do
    if Enum.empty?(enum) do
      nil
    else
      Enum.min_by(enum, func)
    end
  end

  @doc ~S"""
  Find the next step a combatant should take toward a position.

  If a position is returned, it will always be reachable (not blocked).

  ## Parameters

  - arena: The current arena
  - mover: The combatant who will be moving
  - candidate: The candidate position to move toward

  ## Returns

  Position to move toward, or `nil` if no such position exists

  ## Example

  # Mover: {{0, 0}, :elf, 3, 200}
  # Position: {1, 2}

  # Surrounding Me: [
  #   {{0, 1}, {{0, 0}, :elf, 3, 200}},
  #   {{1, 0}, {{0, 0}, :elf, 3, 200}},
  # ]

  # Nearest To Him: [
  #   {{0, 1}, {{0, 0}, :elf, 3, 200}},
  #   {{1, 0}, {{0, 0}, :elf, 3, 200}},
  # ]

      iex> arena = {%{
      ...>     {0, 0} => :combatant,  {0, 1} => :floor,  {0, 2} => :floor,
      ...>     {1, 0} => :floor,      {1, 1} => :floor,  {1, 2} => :floor,
      ...>     {2, 0} => :floor,      {2, 1} => :floor,  {2, 2} => :combatant,
      ...>   }, MapSet.new([
      ...>     {{0, 0}, :elf, 3, 200},
      ...>     {{2, 2}, :goblin, 3, 2},
      ...>   ])
      ...> }
      iex> mover = {{0, 0}, :elf, 3, 200}
      iex> candidate = {{1, 2}, {{2, 2}, :goblin, 3, 2}}
      iex> Combat.Arena.next_step_toward(arena, mover, candidate)
      {0, 1}
  """
  @spec next_step_toward(arena(), combatant(), candidate()) :: position()
  def next_step_toward(_arena, _mover, nil) do
    nil
  end
  def next_step_toward({grid, _roster}, mover, {position, _opponents}) do
    #IO.inspect(mover, label: "Mover")
    #IO.inspect(position, label: "Position")
    floor_squares_around(grid, mover)
    #|> IO.inspect(label: "Surrounding Me")
    |> multi_min_by(fn ({pos, _}) -> manhattan(position, pos) end)
    #|> IO.inspect(label: "Nearest To Him")
    # choose first position in "reading order":
    |> Enum.min_by(fn (candidate) -> elem(candidate, 0) end)
    |> elem(0)
    #|> IO.inspect(label: "Step")
  end

  @doc ~S"""
  Are there opponents adjacent to this combatant?

  ## Examples

      iex> arena = {%{
      ...>     {0, 0} => :combatant,  {0, 1} => :floor,  {0, 2} => :floor,
      ...>     {1, 0} => :combatant,  {1, 1} => :floor,  {1, 2} => :floor,
      ...>     {2, 0} => :rock,       {2, 1} => :floor,  {2, 2} => :combatant,
      ...>   }, MapSet.new([
      ...>     {{0, 0}, :elf, 3, 50},
      ...>     {{1, 0}, :elf, 3, 200},
      ...>     {{2, 2}, :goblin, 3, 2},
      ...>   ])
      ...> }
      iex> combatant = {{1, 0}, :elf, 3, 200}
      iex> Combat.Arena.opponents_near?(arena, combatant)
      false

      iex> arena = {%{
      ...>     {0, 0} => :combatant,  {0, 1} => :floor,      {0, 2} => :floor,
      ...>     {1, 0} => :combatant,  {1, 1} => :combatant,  {1, 2} => :floor,
      ...>     {2, 0} => :rock,       {2, 1} => :floor,      {2, 2} => :floor,
      ...>   }, MapSet.new([
      ...>     {{0, 0}, :elf, 3, 50},
      ...>     {{1, 0}, :elf, 3, 200},
      ...>     {{1, 1}, :goblin, 3, 2},
      ...>   ])
      ...> }
      iex> combatant = {{1, 0}, :elf, 3, 200}
      iex> Combat.Arena.opponents_near?(arena, combatant)
      true
  """
  @spec opponents_near?(arena(), combatant()) :: boolean()
  def opponents_near?(arena, {pos, team, pw, hp}) do
    combatants_around(arena, {pos, team, pw, hp}, opponent(team)) != []
  end

  @spec combatants_around(arena(), combatant(), team()) :: [candidate()]
  defp combatants_around({grid, roster}, {{y, x}, _team, _pw, _hp}, vs_team) do
    [  # in "reading order":
      {y-1, x},
      {y, x-1},
      {y, x+1},
      {y+1, x},
    ]
    |> Enum.filter(fn pos -> grid[pos] == :combatant end)
    |> Enum.filter(fn pos ->
      Enum.any?(roster, fn {c_pos, c_team, _pw, _hp} ->
        (c_pos == pos) && (c_team == vs_team)
      end)
    end)
    #|> IO.inspect(label: "combatants around #{y},#{x}")
  end

  @doc ~S"""
  Move a combatant to a new position.

  ## Example

      iex> arena = {%{
      ...>     {0, 0} => :combatant,  {0, 1} => :floor,  {0, 2} => :floor,
      ...>     {1, 0} => :rock,       {1, 1} => :floor,  {1, 2} => :floor,
      ...>     {2, 0} => :floor,      {2, 1} => :rock,   {2, 2} => :combatant,
      ...>   }, MapSet.new([
      ...>     {{0, 0}, :elf, 3, 200},
      ...>     {{2, 2}, :goblin, 3, 2},
      ...>   ])
      ...> }
      iex> combatant = {{0, 0}, :elf, 3, 200}
      iex> {arena_m, combatant_m} = Combat.Arena.move(arena, combatant, {0, 1})
      iex> arena_m
      {%{
          {0, 0} => :floor,  {0, 1} => :combatant,  {0, 2} => :floor,
          {1, 0} => :rock,   {1, 1} => :floor,      {1, 2} => :floor,
          {2, 0} => :floor,  {2, 1} => :rock,       {2, 2} => :combatant,
        }, MapSet.new([
          {{0, 1}, :elf, 3, 200},
          {{2, 2}, :goblin, 3, 2},
        ])
      }
      iex> combatant_m
      {{0, 1}, :elf, 3, 200}
  """
  @spec move(arena(), combatant(), position()) :: {arena(), combatant()}
  def move({grid, roster}, {old_pos, team, pw, hp}, new_pos) do
    cond do
      new_pos == nil ->
        raise "attempt to move nowhere"
      (old_pos != new_pos) && manhattan(old_pos, new_pos) != 1 ->
        raise "attempt to move more than one square"
      old_pos != new_pos ->
        new_grid = grid
               |> Map.replace!(old_pos, :floor)
               |> Map.replace!(new_pos, :combatant)
        new_roster = roster
                 |> MapSet.delete({old_pos, team, pw, hp})
                 |> MapSet.put({new_pos, team, pw, hp})
        {old_pos, team, pw, hp}
        #|> IO.inspect(label: "<<<<< moved needed from")
        {new_pos, team, pw, hp}
        #|> IO.inspect(label: "<<<<< moved needed to")
        {{new_grid, new_roster}, {new_pos, team, pw, hp}}
      old_pos == new_pos ->
        {old_pos, team, pw, hp}
        #|> IO.inspect(label: "===== no move needed by")
        {{grid, roster}, {old_pos, team, pw, hp}}
    end
  end
end
