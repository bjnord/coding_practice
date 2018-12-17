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

  ###
  # PARSING
  ###

  @doc ~S"""
  Parse a complete puzzle.

  ## Example

      iex> {grid, roster} = Combat.Arena.parse_puzzle([
      ...>   "#E#\n",
      ...>   ".G.\n",
      ...> ])
      iex> grid
      %{
        {0, 0} => :rock,
        {0, 1} => :combatant,
        {0, 2} => :rock,
        {1, 0} => :floor,
        {1, 1} => :combatant,
        {1, 2} => :floor,
      }
      iex> roster
      #MapSet<[{{0, 1}, :elf, 3, 200, 1}, {{1, 1}, :goblin, 3, 200, 2}]>
  """
  @spec parse_puzzle([String.t()]) :: arena()
  def parse_puzzle(lines) when is_list(lines) do
    Enum.reduce(lines, {0, {{%{}, MapSet.new()}, 1}}, fn (line, {y, {{grid, roster}, jersey_id}}) ->
      {y+1, parse_line({{grid, roster}, jersey_id}, line, y)}
    end)
    |> elem(1)
    |> elem(0)
  end

  @doc ~S"""
  Parse a line from the initial state, adding its data to accumulators.

  ## Example

      iex> {{grid, roster}, jersey_id} = Combat.Arena.parse_line({{%{}, MapSet.new()}, 1}, "  #GE#.E..  \n", 42)
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
      #MapSet<[{{42, 3}, :goblin, 3, 200, 1}, {{42, 4}, :elf, 3, 200, 2}, {{42, 7}, :elf, 3, 200, 3}]>
      iex> jersey_id
      4
  """
  @spec parse_line({arena(), non_neg_integer()}, String.t(), non_neg_integer()) :: {arena(), non_neg_integer()}
  def parse_line({{grid, roster}, jersey_id}, line, y) when is_binary(line) do
    line
    |> String.trim_trailing
    |> String.graphemes
    |> Enum.with_index
    |> Enum.reduce({{grid, roster}, jersey_id}, fn ({square, x}, {{grid_a, roster_a}, jersey_id}) ->
      case square_type(square) do
        {:square, kind} ->
          {
            {
              Map.put(grid_a, {y, x}, kind),
              roster_a,
            }, jersey_id,
          }
        {:combatant, team} ->
          {
            {
              Map.put(grid_a, {y, x}, :combatant),
              MapSet.put(roster_a, {{y, x}, team, 3, 200, jersey_id}),
            }, jersey_id+1,
          }
        {:void} ->
          {{grid_a, roster_a}, jersey_id}
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

  ###
  # MOVEMENT AND COMBAT
  ###

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
      ...>   {{42, 3}, :elf, 3, 200, 1},
      ...>   {{42, 4}, :goblin, 3, 2, 2},
      ...>   {{42, 7}, :elf, 3, 200, 3},
      ...> ])}
      iex> Combat.Arena.find_combatants(arena, :goblin)
      [{{42, 4}, :goblin, 3, 2, 2}]

      iex> arena = {%{}, MapSet.new([
      ...>   {{42, 3}, :elf, 3, 200, 1},
      ...>   {{42, 7}, :elf, 3, 200, 2},
      ...> ])}
      iex> Combat.Arena.find_combatants(arena, :goblin)
      []
  """
  @spec find_combatants(arena(), team()) :: boolean()
  def find_combatants({_grid, roster}, team) do
    Enum.filter(roster, fn ({_pos, c_team, _pw, _hp, _id}) -> c_team == team end)
  end

  @doc ~S"""
  Fight a whole battle.

  ## Returns

  Final arena, and number of rounds fought (**including** a potential
  incomplete final round).
  """
  @spec battle(arena(), atom()) :: {arena(), non_neg_integer()}
  def battle(arena, style) do
    1..1_000_000
    |> Enum.reduce_while(arena, fn (round, arena) ->
      {arena, done} = fight(arena, style)
      case done do
        true ->
          {:halt, {arena, round}}
        false ->
          ###
          # DEBUG: dump each step, stop at round, etc.
          #dump_arena(arena, round)
          #if round == 26 do
          #  raise "DEBUG: quit here to inspect"
          #end
          # END DEBUG
          ###
          {:cont, arena}
      end
    end)
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

  ## Examples

      iex> arena = {%{
      ...>     {0, 0} => :combatant,  {0, 1} => :floor,  {0, 2} => :floor,
      ...>     {1, 0} => :rock,       {1, 1} => :floor,  {1, 2} => :floor,
      ...>     {2, 0} => :floor,      {2, 1} => :rock,   {2, 2} => :combatant,
      ...>   }, MapSet.new([
      ...>     {{0, 0}, :elf, 3, 200, 1},
      ...>     {{2, 2}, :goblin, 3, 2, 2},
      ...>   ])
      ...> }
      iex> Combat.Arena.fight(arena, :pacifist) |> elem(0)
      {%{
          {0, 0} => :floor,  {0, 1} => :combatant,  {0, 2} => :floor,
          {1, 0} => :rock,   {1, 1} => :floor,      {1, 2} => :combatant,
          {2, 0} => :floor,  {2, 1} => :rock,       {2, 2} => :floor,
        }, MapSet.new([
          {{0, 1}, :elf, 3, 200, 1},
          {{1, 2}, :goblin, 3, 2, 2},
        ])
      }

      iex> arena = {%{
      ...>     {0, 0} => :floor,  {0, 1} => :combatant,  {0, 2} => :rock,
      ...>     {1, 0} => :rock,   {1, 1} => :floor,      {1, 2} => :combatant,
      ...>     {2, 0} => :floor,  {2, 1} => :rock,       {2, 2} => :floor,
      ...>   }, MapSet.new([
      ...>     {{0, 1}, :elf, 3, 200, 1},
      ...>     {{1, 2}, :goblin, 2, 20, 2},
      ...>   ])
      ...> }
      iex> Combat.Arena.fight(arena, :puzzle) |> elem(0)
      {%{
          {0, 0} => :floor,  {0, 1} => :floor,      {0, 2} => :rock,
          {1, 0} => :rock,   {1, 1} => :combatant,  {1, 2} => :combatant,
          {2, 0} => :floor,  {2, 1} => :rock,       {2, 2} => :floor,
        }, MapSet.new([
          {{1, 1}, :elf, 3, 198, 1},
          {{1, 2}, :goblin, 2, 17, 2},
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
      [{pos, team, pw, hp, id} | f_left] = f_left
      if Enum.find(roster_a, fn (combatant) -> elem(combatant, 4) == id end) == nil do
        # gotcha: if fighter died, they don't get to take a turn
        {:cont, {{grid_a, roster_a}, f_left}}
      else
        opponents = find_combatants({grid_a, roster_a}, opponent(team))
        if opponents != [] do
          {grid_a, roster_a} = fight_in_style({grid_a, roster_a}, {pos, team, pw, hp, id}, opponents, style)
          if f_left != [] do
            {:cont, {{grid_a, roster_a}, f_left}}
          else
            {:halt, {{grid_a, roster_a}, false}}
          end
        else
          {:halt, {{grid_a, roster_a}, true}}
        end
      end
    end)
    #|> IO.inspect(label: "ding ding ding")
  end

  # fight_in_style(): one fighter takes their turn
  @spec fight_in_style(arena(), combatant(), [combatant()], atom()) :: arena()

  defp fight_in_style({grid, roster}, fighter, opponents, :pacifist) do
    #IO.inspect(fighter, label: "next fighter (pacifist)")
    {{grid, roster}, _fighter} =
      movement_phase({grid, roster}, fighter, opponents)
    {grid, roster}
  end

  defp fight_in_style({grid, roster}, fighter, opponents, :puzzle) do
    #IO.inspect(fighter, label: "next fighter (puzzle)")
    {{grid, roster}, fighter} =
      movement_phase({grid, roster}, fighter, opponents)
    attack_phase({grid, roster}, fighter)
  end

  defp movement_phase({grid, roster}, fighter, opponents) do
    if opponents_near?({grid, roster}, fighter) do
      {{grid, roster}, fighter}  # no need to move
    else
      candidate = next_position({grid, roster}, fighter, opponents)
      next_step = next_step_toward({grid, roster}, fighter, candidate)
      if next_step == nil do
        {{grid, roster}, fighter}  # no place to move
      else
        move({grid, roster}, fighter, next_step)
      end
    end
  end

  defp attack_phase({grid, roster}, {pos, team, pw, hp, id}) do
    combatants =
      combatants_around({grid, roster}, {pos, team, pw, hp, id}, opponent(team))
      |> multi_min_by(&(elem(&1, 3)))  # lowest HP
      #|> IO.inspect(label: "Lowest HP")
    if (combatants != nil) && (combatants != []) do
      target = Enum.min_by(combatants, &(elem(&1, 0)))  # "reading order"
               #|> IO.inspect(label: "Reading Order")
      attack({grid, roster}, {pos, team, pw, hp, id}, target)
      |> elem(0)
    else
      {grid, roster}  # no one to fight
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
      ...>     {{0, 1}, :goblin, 3, 20, 1},
      ...>     {{1, 2}, :goblin, 3, 2, 2},
      ...>     {{2, 0}, :elf, 3, 200, 3},
      ...>   ])
      ...> }
      iex> mover = {{2, 0}, :elf, 3, 200, 3}
      iex> opponents = Combat.Arena.find_combatants(arena, :goblin)
      iex> Combat.Arena.next_position(arena, mover, opponents) |> elem(0)
      {0, 0}

      iex> arena = {%{
      ...>     {0, 0} => :rock,
      ...>     {0, 1} => :combatant,
      ...>     {1, 0} => :combatant,
      ...>     {1, 1} => :rock,
      ...>   }, MapSet.new([
      ...>     {{0, 1}, :goblin, 3, 2, 1},
      ...>     {{1, 0}, :elf, 3, 200, 2},
      ...>   ])
      ...> }
      iex> mover = {{1, 0}, :elf, 3, 200, 2}
      iex> opponents = Combat.Arena.find_combatants(arena, :goblin)
      iex> Combat.Arena.next_position(arena, mover, opponents)
      nil
  """
  @spec next_position(arena(), combatant(), roster()) :: candidate()
  def next_position({grid, roster}, mover, opponents) do
    # this is a "forward" path check, from mover to candidate position(s)
    distances = path_distances(grid, elem(mover, 0))
                #|> IO.inspect(label: "forward distances")
    #IO.inspect(mover, label: "Mover")
    candidates_in_range({grid, roster}, mover, opponents)
    #|> IO.inspect(label: "In range")
    |> reachable_candidates({grid, roster}, mover, opponents, distances)
    #|> IO.inspect(label: "Reachable")
    |> nearest_candidates({grid, roster}, mover, opponents, distances)
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
  # TODO can this be refactored to use positions_around() ?
  defp floor_squares_around(grid, combatant) do
    {{y, x}, _team, _pw, _hp, _id} = combatant
    [  # in "reading order":
      {{y-1, x}, combatant},
      {{y, x-1}, combatant},
      {{y, x+1}, combatant},
      {{y+1, x}, combatant},
    ]
    |> Enum.filter(fn ({pos, _combatant}) -> grid[pos] == :floor end)
  end

  @spec reachable_candidates([candidate()], arena(), combatant(), roster(), map()) :: [candidate()]
  defp reachable_candidates(candidates, _arena, _mover, _opponents, distances) do
    Enum.filter(candidates, fn ({pos, _opponents}) -> distances[pos] end)
  end

  @spec nearest_candidates([candidate()], arena(), combatant(), roster(), map()) :: [candidate()]
  defp nearest_candidates(candidates, _arena, _mover, _opponents, distances) do
    multi_min_by(candidates, fn ({pos, _opponents}) -> distances[pos] end)
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
  def multi_min_by(enum, func) do
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
      ...>     {{0, 0}, :elf, 3, 200, 1},
      ...>     {{2, 2}, :goblin, 3, 2, 2},
      ...>   ])
      ...> }
      iex> mover = {{0, 0}, :elf, 3, 200, 1}
      iex> candidate = {{1, 2}, {{2, 2}, :goblin, 3, 2, 2}}
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
    # this is a "reverse" path check, from candidate position back to
    # the squares around mover (move options)
    distances = path_distances(grid, position)
                #|> IO.inspect(label: "distances")
    possible_steps =
      floor_squares_around(grid, mover)
      #|> IO.inspect(label: "Surrounding Me")
      |> multi_min_by(fn ({pos, _}) -> distances[pos] end)
      #|> IO.inspect(label: "Nearest To Him")
    if possible_steps != [] do
      # choose first position in "reading order":
      possible_steps
      |> Enum.min_by(fn (candidate) -> elem(candidate, 0) end)
      |> elem(0)
    else
      # TODO once reachable_candidates() is done, this may never
      #      happen; change to "raise"
      nil
    end
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
      ...>     {{0, 0}, :elf, 3, 50, 1},
      ...>     {{1, 0}, :elf, 3, 200, 2},
      ...>     {{2, 2}, :goblin, 3, 2, 3},
      ...>   ])
      ...> }
      iex> combatant = {{1, 0}, :elf, 3, 200, 2}
      iex> Combat.Arena.opponents_near?(arena, combatant)
      false

      iex> arena = {%{
      ...>     {0, 0} => :combatant,  {0, 1} => :floor,      {0, 2} => :floor,
      ...>     {1, 0} => :combatant,  {1, 1} => :combatant,  {1, 2} => :floor,
      ...>     {2, 0} => :rock,       {2, 1} => :floor,      {2, 2} => :floor,
      ...>   }, MapSet.new([
      ...>     {{0, 0}, :elf, 3, 50, 1},
      ...>     {{1, 0}, :elf, 3, 200, 2},
      ...>     {{1, 1}, :goblin, 3, 2, 3},
      ...>   ])
      ...> }
      iex> combatant = {{1, 0}, :elf, 3, 200, 2}
      iex> Combat.Arena.opponents_near?(arena, combatant)
      true
  """
  @spec opponents_near?(arena(), combatant()) :: boolean()
  def opponents_near?(arena, {pos, team, pw, hp, id}) do
    combatants_around(arena, {pos, team, pw, hp, id}, opponent(team)) != []
  end

  @doc ~S"""
  Find opponent positions adjacent to a combatant.

  ## Examples

      iex> arena = {%{
      ...>     {0, 0} => :combatant,  {0, 1} => :floor,      {0, 2} => :floor,
      ...>     {1, 0} => :combatant,  {1, 1} => :combatant,  {1, 2} => :floor,
      ...>     {2, 0} => :rock,       {2, 1} => :floor,      {2, 2} => :floor,
      ...>   }, MapSet.new([
      ...>     {{0, 0}, :elf, 3, 50, 1},
      ...>     {{1, 0}, :elf, 3, 200, 2},
      ...>     {{1, 1}, :goblin, 3, 2, 3},
      ...>   ])
      ...> }
      iex> combatant = {{1, 0}, :elf, 3, 200, 2}
      iex> Combat.Arena.combatants_around(arena, combatant, :goblin)
      [{{1, 1}, :goblin, 3, 2, 3}]
  """
  @spec combatants_around(arena(), combatant(), team()) :: [combatant()]
  # TODO can this be refactored to use positions_around() ?
  def combatants_around({grid, roster}, {{y, x}, _team, _pw, _hp, _id}, vs_team) do
    [  # in "reading order":
      {y-1, x},
      {y, x-1},
      {y, x+1},
      {y+1, x},
    ]
    |> Enum.filter(fn (pos) -> grid[pos] == :combatant end)
    |> Enum.map(fn (pos) ->
      Enum.find(roster, fn {c_pos, c_team, _pw, _hp, _id} ->
        (c_pos == pos) && (c_team == vs_team)
      end)
    end)
    |> Enum.filter(fn (comb) -> comb end)
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
      ...>     {{0, 0}, :elf, 3, 200, 1},
      ...>     {{2, 2}, :goblin, 3, 2, 2},
      ...>   ])
      ...> }
      iex> combatant = {{0, 0}, :elf, 3, 200, 1}
      iex> {arena_m, combatant_m} = Combat.Arena.move(arena, combatant, {0, 1})
      iex> arena_m
      {%{
          {0, 0} => :floor,  {0, 1} => :combatant,  {0, 2} => :floor,
          {1, 0} => :rock,   {1, 1} => :floor,      {1, 2} => :floor,
          {2, 0} => :floor,  {2, 1} => :rock,       {2, 2} => :combatant,
        }, MapSet.new([
          {{0, 1}, :elf, 3, 200, 1},
          {{2, 2}, :goblin, 3, 2, 2},
        ])
      }
      iex> combatant_m
      {{0, 1}, :elf, 3, 200, 1}
  """
  @spec move(arena(), combatant(), position()) :: {arena(), combatant()}
  def move({grid, roster}, {old_pos, team, pw, hp, id}, new_pos) do
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
                 |> MapSet.delete({old_pos, team, pw, hp, id})
                 |> MapSet.put({new_pos, team, pw, hp, id})
        #{old_pos, team, pw, hp, id}
        #|> IO.inspect(label: "<<<<< moved needed from")
        #{new_pos, team, pw, hp, id}
        #|> IO.inspect(label: "<<<<< moved needed to")
        {{new_grid, new_roster}, {new_pos, team, pw, hp, id}}
      old_pos == new_pos ->
        #{old_pos, team, pw, hp, id}
        #|> IO.inspect(label: "===== no move needed by")
        {{grid, roster}, {old_pos, team, pw, hp, id}}
    end
  end

  @doc ~S"""
  Attack an opponent.

  ## Example

      iex> arena = {%{
      ...>     {0, 0} => :floor,  {0, 1} => :floor,      {0, 2} => :floor,
      ...>     {1, 0} => :rock,   {1, 1} => :combatant,  {1, 2} => :combatant,
      ...>     {2, 0} => :floor,  {2, 1} => :rock,       {2, 2} => :floor,
      ...>   }, MapSet.new([
      ...>     {{1, 1}, :elf, 3, 200, 1},
      ...>     {{1, 2}, :goblin, 3, 20, 2},
      ...>   ])
      ...> }
      iex> combatant = {{1, 1}, :elf, 3, 200, 1}
      iex> opponent = {{1, 2}, :goblin, 3, 20, 2}
      iex> {arena_a, opponent_a} = Combat.Arena.attack(arena, combatant, opponent)
      iex> arena_a
      {%{
          {0, 0} => :floor,  {0, 1} => :floor,      {0, 2} => :floor,
          {1, 0} => :rock,   {1, 1} => :combatant,  {1, 2} => :combatant,
          {2, 0} => :floor,  {2, 1} => :rock,       {2, 2} => :floor,
        }, MapSet.new([
          {{1, 1}, :elf, 3, 200, 1},
          {{1, 2}, :goblin, 3, 17, 2},
        ])
      }
      iex> opponent_a
      {{1, 2}, :goblin, 3, 17, 2}
  """
  @spec attack(arena(), combatant(), combatant()) :: {arena(), combatant()}
  def attack({grid, roster}, {pos, _team, pw, _hp, _id}, {o_pos, o_team, o_pw, o_hp, o_id}) do
    new_opponent = {o_pos, o_team, o_pw, o_hp - pw, o_id}
    {new_grid, new_roster} =
      cond do
        manhattan(pos, o_pos) != 1 ->
          raise "attempt to attack more than one square away"
        o_hp > pw ->
          new_roster =
            roster
            |> MapSet.delete({o_pos, o_team, o_pw, o_hp, o_id})
            |> MapSet.put(new_opponent)
          {grid, new_roster}
        o_hp <= pw ->
          new_grid =
            Map.replace!(grid, o_pos, :floor)
          new_roster =
            roster
            |> MapSet.delete({o_pos, o_team, o_pw, o_hp, o_id})
          {new_grid, new_roster}
      end
    #{o_pos, o_team, o_pw, o_hp, o_id}
    #|> IO.inspect(label: "<<<<< attack before")
    #new_opponent
    #|> IO.inspect(label: ">>>>> attack after")
    {{new_grid, new_roster}, new_opponent}
  end

  ###
  # PATH FINDING
  ###

  @doc ~S"""
  Find distance to all points from a position.

  ## Examples

      iex> grid = %{
      ...>   {0, 0} => :combatant,  {0, 1} => :floor,      {0, 2} => :floor,
      ...>   {1, 0} => :rock,       {1, 1} => :combatant,  {1, 2} => :floor,
      ...>   {2, 0} => :floor,      {2, 1} => :floor,      {2, 2} => :floor,
      ...> }
      iex> origin = {0, 0}
      iex> Combat.Arena.path_distances(grid, origin)
      %{
        {0, 0} => 0,    {0, 1} => 1,    {0, 2} => 2,
        {1, 0} => nil,  {1, 1} => nil,  {1, 2} => 3,
        {2, 0} => 6,    {2, 1} => 5,    {2, 2} => 4,
      }

      iex> grid = %{
      ...>   {0, 0} => :floor,      {0, 1} => :floor,  {0, 2} => :rock,
      ...>   {1, 0} => :combatant,  {1, 1} => :rock,   {1, 2} => :floor,
      ...>   {2, 0} => :floor,      {2, 1} => :floor,  {2, 2} => :rock,
      ...> }
      iex> origin = {1, 0}
      iex> Combat.Arena.path_distances(grid, origin)
      %{
        {0, 0} => 1,  {0, 1} => 2,    {0, 2} => nil,
        {1, 0} => 0,  {1, 1} => nil,
        {2, 0} => 1,  {2, 1} => 2,    {2, 2} => nil,
      }
  """
  @spec path_distances(grid(), position()) :: map()
  def path_distances(grid, origin) do
    limit = path_limit(grid)
            #|> IO.inspect(label: "<pf> Path limit")
    {seen, _positions} =
      0..limit
      |> Enum.reduce({%{origin => 0}, [origin]}, fn (dist, {seen, next_posns}) ->
        Enum.reduce(next_posns, {seen, []}, fn (next_pos, {seen, pos_acc}) ->
          {seen, surr_posns} =
            path_distances_around(grid, seen, next_pos, dist)
          {seen, pos_acc ++ surr_posns}
        end)
        #|> IO.inspect(label: "<pf> (outer) New positions @ dist=#{dist}")
      end)
    seen
  end

  @spec path_distances_around(grid(), map(), position(), integer()) :: {map(), [position()]}
  defp path_distances_around(grid, seen, pos, dist) do
    #{db_y, db_x} = pos  # for <pf> IO.inspect, below
    unseen_positions_around(grid, pos, seen)
    #|> IO.inspect(label: "<pf> (inner) Unseen #{db_y},#{db_x} (dist=#{dist})")
    |> Enum.reduce({seen, []}, fn (v_pos, {seen, added_pos}) ->
      # NB unseen_positions include impassable ones:
      #    (1) we add those to the path_map (seen), so they get distance=nil
      #    (2) but we DON'T add them to the accumulator (no further traversal)
      seen = add_to_path_map(v_pos, grid[v_pos], seen, dist+1)
      case grid[v_pos] do
        :floor ->
          {seen, [v_pos | added_pos]}
        _ ->
          {seen, added_pos}
      end
    end)
    #|> IO.inspect(label: "<pf> (inner) Around #{db_y},#{db_x} (dist=#{dist})")
  end

  defp add_to_path_map(pos, :floor, seen, dist) do
    Map.put(seen, pos, dist)
  end

  defp add_to_path_map(pos, _sq_type, seen, _dist) do
    Map.put(seen, pos, nil)
  end

  # these are "potential paths forward" (branches that start with squares around me
  # that are in the grid, but that I haven't seen yet)
  defp unseen_positions_around(grid, pos, seen) do
    positions_around(pos)
    |> Enum.reject(fn (p) -> (grid[p] == nil) || Map.has_key?(seen, p) end)
  end

  defp positions_around({y, x}) do
    [  # in "reading order":
      {y-1, x},
      {y, x-1},
      {y, x+1},
      {y+1, x},
    ]
  end

  # OPTIMIZE n^2 is the "safe" value (all squares);
  #          it could be smaller e.g. a "maze" has lots of rock
  defp path_limit(grid) do
    {min_y, max_y} =
      Map.keys(grid)
      |> Enum.map(&(elem(&1, 0)))
      |> Enum.min_max
    (max_y-min_y+1) * (max_y-min_y+1)
  end

  ###
  # TESTING SUPPORT
  ###

  def dump_arena({grid, roster}, round \\ nil) do
    max_y =
      Map.keys(grid)
      |> Enum.max_by(&(elem(&1, 0)))
      |> elem(0)
    case round do
      nil ->
        nil
      0 ->
        IO.puts("Initially:")
      1 ->
        IO.puts("After 1 round:")
      _ ->
        IO.puts("After #{round} rounds:")
    end
    0..max_y
    |> Enum.map(fn (y) -> dump_arena_line(y, {grid, roster}) end)
    IO.write("\n")
  end

  defp dump_arena_line(y, {grid, roster}) do
    Map.keys(grid)
    |> Enum.filter(&(elem(&1, 0) == y))
    |> Enum.sort()
    |> Enum.map(&(emit_square(&1, {grid, roster})))
    IO.write("   ")
    # TODO emit HP here for combatants on this row
    IO.write("\n")
  end

  defp emit_square(pos, {grid, roster}) do
    case grid[pos] do
      :rock -> '#'
      :floor -> '.'
      :combatant ->
        combatant =
          Enum.find(roster, &(elem(&1, 0) == pos))
        team =
          if combatant, do: elem(combatant, 1), else: nil
        case team do
          :elf -> 'E'
          :goblin -> 'G'
          _ -> '?'
        end
      _ -> ' '
    end
    |> IO.write
  end
end
