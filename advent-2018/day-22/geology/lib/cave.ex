defmodule Cave do
  @moduledoc """
  Documentation for Cave.
  """

  @enforce_keys [:depth, :target, :bounds]
  defstruct depth: nil, target: {nil, nil}, bounds: {nil, nil}, erosion: %{}, path_cost: %{}

  @type position() :: {integer(), integer()}
  @type position_range() :: {Range.t(integer()), Range.t(integer())}
  @type t() :: %__MODULE__{
    depth: integer(),
    target: position(),
    bounds: position(),
    erosion: map(),
    path_cost: map(),
  }

  @tool_switch_cost 7
  @walk_cost 1

  @doc """
  Construct a new cave.
  """
  @spec new(integer(), position(), integer()) :: Cave.t()

  def new(depth, {y, x}, margin_x, margin_y \\ nil) when is_integer(depth) and is_integer(y) and is_integer(x) do
    margin_y =
      if margin_y do
        margin_y
      else
        margin_x  # caller wants equal margins
      end
    %Cave{depth: depth, target: {y, x}, bounds: {y+margin_y, x+margin_x}, erosion: %{}, path_cost: %{}}
  end

  @doc """
  Compute geologic index at a position.

  ## Example

      iex> cave = Cave.new(510, {10, 10}, 5)
      iex> Cave.geologic_index(cave, {0, 0})
      0
      iex> Cave.geologic_index(cave, {0, 1})
      16807
      iex> Cave.geologic_index(cave, {1, 0})
      48271
      iex> Cave.geologic_index(cave, {1, 1})
      145722555
      iex> Cave.geologic_index(cave, {10, 10})
      0
  """
  @spec geologic_index(Cave.t(), position()) :: integer()

  def geologic_index(_cave, {y, x}) when {y, x} == {0, 0} do
    0
  end

  def geologic_index(_cave, {y, x}) when (y == 0) do
    x * 16807
  end

  def geologic_index(_cave, {y, x}) when (x == 0) do
    y * 48271
  end

  def geologic_index(cave, {y, x}) do
    if {y, x} == cave.target do
      0
    else
      erosion_level(cave, {y-1, x}) * erosion_level(cave, {y, x-1})
    end
  end

  @doc """
  Compute erosion level at a position.

  ## Example

      iex> cave = Cave.new(510, {10, 10}, 5)
      iex> Cave.erosion_level(cave, {0, 0})
      510
      iex> Cave.erosion_level(cave, {0, 1})
      17317
      iex> Cave.erosion_level(cave, {1, 0})
      8415
      iex> Cave.erosion_level(cave, {1, 1})
      1805
      iex> Cave.erosion_level(cave, {10, 10})
      510
  """
  @spec erosion_level(Cave.t(), position()) :: integer()

  def erosion_level(cave, {y, x}) do
    if Map.has_key?(cave.erosion, {y, x}) do
      Map.get(cave.erosion, {y, x})
    else
      rem(geologic_index(cave, {y, x}) + cave.depth, 20183)
    end
  end

  @doc """
  Get region type at a position.

  ## Example

      iex> cave = Cave.new(510, {10, 10}, 5)
      iex> Cave.region_type(cave, {0, 0})
      :rocky
      iex> Cave.region_type(cave, {0, 1})
      :wet
      iex> Cave.region_type(cave, {1, 0})
      :rocky
      iex> Cave.region_type(cave, {1, 1})
      :narrow
      iex> Cave.region_type(cave, {10, 10})
      :rocky
  """
  @spec region_type(Cave.t(), position()) :: atom()

  def region_type(cave, {y, x}) do
    case risk_level(cave, {y, x}) do
      0 -> :rocky
      1 -> :wet
      2 -> :narrow
    end
  end

  @doc """
  Compute total risk level.

  ## Example

      iex> cave = Cave.new(510, {10, 10}, 5)
      iex> Cave.risk_level(cave, {0..10, 0..10})
      114
  """
  @spec risk_level(Cave.t(), position_range()) :: integer()

  def risk_level(cave, {y_range, x_range}) when is_map(y_range) and is_map(x_range) do
    squares =
      for y <- y_range,
        x <- x_range,
        do: risk_level(cave, {y, x})
    Enum.sum(squares)
  end

  @doc """
  Compute risk level at a position.
  """
  @spec risk_level(Cave.t(), position()) :: integer()

  def risk_level(cave, {y, x}) when is_integer(y) and is_integer(x) do
    rem(erosion_level(cave, {y, x}), 3)
  end

  @doc """
  Return range from mouth to target (rectangle).

  ## Example

      iex> cave = Cave.new(100, {7, 9}, 0)
      iex> Cave.target_range(cave)
      {0..7, 0..9}
  """
  @spec target_range(Cave.t()) :: position_range()

  def target_range(cave) do
    {y, x} = cave.target
    {0..y, 0..x}
  end

  @doc """
  Return range from mouth to bounds (rectangle).

  ## Example

      iex> cave = Cave.new(100, {7, 9}, 3)
      iex> Cave.bounds_range(cave)
      {0..10, 0..12}
  """
  @spec bounds_range(Cave.t()) :: position_range()

  def bounds_range(cave) do
    {y, x} = cave.bounds
    {0..y, 0..x}
  end

  @doc """
  Precalculate erosion for a cave.

  Returns the updated cave, with cached erosion levels.

  ## Example

      iex> cave = Cave.new(21, {3, 3}, 1)
      iex> Cave.erosion_level(cave, {1, 1})
      9485
      iex> fast_cave = Cave.cache_erosion(cave)
      iex> Cave.erosion_level(fast_cave, {1, 1})
      9485
      iex> Enum.count(fast_cave.erosion)
      25
  """
  @spec cache_erosion(Cave.t()) :: Cave.t()

  # TODO OPTIMIZE can this be parallelized?
  def cache_erosion(cave) do
    {range_y, range_x} = bounds_range(cave)
    ###
    # we want reduce here, so {y, x} can take advantage of cached {y-1, x}
    # etc. as we go
    Enum.reduce(range_y, cave, fn (y, cave) ->
      Enum.reduce(range_x, cave, fn (x, cave) ->
        if Map.has_key?(cave.erosion, {y, x}) do
          cave
        else
          %{cave | erosion: Map.put(cave.erosion, {y, x}, erosion_level(cave, {y, x}))}
        end
      end)
    end)
  end

  @doc """
  Generate printable map of a cave.
  """
  @spec map(Cave.t(), position_range()) :: [String.t()]

  def map(cave, {y_range, x_range}) do
    for y <- y_range,
      do: map_row(cave, y, x_range)
  end

  @spec map_row(Cave.t(), integer(), Range.t(integer())) :: String.t()

  defp map_row(cave, y, x_range) do
    row =
      for x <- x_range,
        do: map_position(cave, {y, x})
    row
    |> to_string()
  end

  @spec map_position(Cave.t(), position()) :: integer()

  defp map_position(_cave, position) when position == {0, 0} do
    ?M
  end

  defp map_position(cave, position) do
    rtype = region_type(cave, position)
    cond do
      cave.target == position -> ?T
      rtype == :rocky -> ?.
      rtype == :wet -> ?=
      rtype == :narrow -> ?|
    end
  end

  @doc """
  Find the cost of moving to a neighboring position.

  Returns
  - new total cost (accounting for tool switch, if any)
  - new equipped tool (same one if switch wasn't required)
  """
  @spec neighbor_move_cost(Cave.t(), integer(), atom(), atom(), position()) :: {integer(), atom()}

  def neighbor_move_cost(_, _, _, _, {y, x}) when (y < 0) or (x < 0) do
    {nil, nil}
  end

  def neighbor_move_cost(cave, cost, old_tool, old_region, {y, x}) do
    {by, bx} = cave.bounds
    if (y > by) or (x > bx) do
      {nil, nil}
    else
      new_region = region_type(cave, {y, x})
      {new_cost, new_tool} = best_tool_cost(cost, old_tool, old_region, new_region)
      add_target_cost(cave, new_cost, {y, x}, new_tool)
    end
  end

  @spec best_tool_cost(integer(), atom(), atom(), atom()) :: {integer(), atom()}

  defp best_tool_cost(nil, _, _, _) do
    {nil, nil}
  end

  defp best_tool_cost(cost, old_tool, old_region, new_region) do
    if tool_usable?(old_tool, new_region) do
      # if old tool usable in new region, keep it (no switch cost)
      {cost + @walk_cost, old_tool}
    else
      # otherwise must switch; new tool must be usable @ both old and
      # new region -- at least one tool will always qualify
      new_tool =
        [:gear, :torch, :nothing]
        |> Enum.find(fn (tool) ->
          (tool != old_tool) &&
            tool_usable?(tool, old_region) &&
            tool_usable?(tool, new_region)
        end)
      {cost + @walk_cost + @tool_switch_cost, new_tool}
    end
  end

  @spec tool_usable?(atom(), atom()) :: boolean()

  defp tool_usable?(tool, new_region) do
    usable =
      case new_region do
        :rocky  -> [:gear, :torch]
        :wet    -> [:gear, :nothing]
        :narrow -> [:torch, :nothing]
      end
    tool in usable
  end

  @spec add_target_cost(Cave.t(), integer(), position(), atom()) :: {integer(), atom()}

  defp add_target_cost(cave, cost, position, tool) do
    # puzzle requirement: when we reach the target, we must pay to equip the :torch
    if (position == cave.target) && (tool != :torch) do
      {cost + @tool_switch_cost, :torch}
    else
      {cost, tool}
    end
  end

  @doc """
  Find lowest-cost path from origin to target.

  Uses [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
  where nodes are in three dimensions (y, x, and "from region").
  """
  @spec cheapest_path(Cave.t(), position(), atom(), position()) :: integer()

  def cheapest_path(_cave, origin, _tool, dest) when origin == dest do
    0
  end

  def cheapest_path(cave, origin, tool, dest) do
    origin_region = region_type(cave, origin)
    validate_cheapest_path_args(cave, origin_region, dest)
    dest_ways = ways_into_dest(cave, dest)
    ###
    # Start nodelist with 1 node for origin, which will become the first
    # current_node. NB That 1 initial node is unclosed, and there must be
    # a path_cost entry for it.
    nodelist = [{{origin, origin_region}, tool}]
    cave = %{cave | path_cost: %{{origin, origin_region} => {0, false}}}
    ###
    # Begin processing from the origin
    process_nodes(cave, nodelist, {dest, dest_ways})
  end

  defp ways_into_dest(cave, {y, x}) do
    # FIXME DRY
    neighbor_positions = [{y-1, x}, {y, x-1}, {y, x+1}, {y+1, x}]
    neighbor_positions
    |> Enum.filter(fn ({y, x}) ->
      {yb, xb} = cave.bounds
      (y in 0..yb) && (x in 0..xb)
    end)
    |> Enum.map(fn (pos) -> region_type(cave, pos) end)
    |> Enum.uniq
    #|> IO.inspect(label: "ways_into_dest()")
  end

  defp validate_cheapest_path_args(cave, origin_region, dest) do
    if origin_region != :rocky do
      raise ArgumentError, "must start from rocky region"
    end
    dest_region = region_type(cave, dest)
    if dest_region != :rocky do
      raise ArgumentError, "must end in rocky region"
    end
    true
  end

  # Dijkstra's algorithm:
  # 1. Find the best new current_node
  # 2. Visit adjacent nodes, updating them to lowest cost
  # 3. Close the current_node
  # 4. Unless we've arrived at the target, go back to 1.
  #
  defp process_nodes(cave, nodelist, destination) do
    Stream.cycle([true])
    |> Enum.reduce_while({cave, nodelist}, fn (_t, {cave, nodelist}) ->
      {nodelist, current_node, current_cost, _} = find_current_node(cave, nodelist, destination)
      #IO.inspect({current_node, :cost, current_cost}, label: "found new current_node")
      if nodelist == [] do
        raise "exhausted nodelist"  # shouldn't happen
      end
      {cave, nodelist} = visit_neighbors(cave, nodelist, current_node, current_cost)
      cave = close_current_node(cave, current_node, current_cost, destination)
      lowest_cost = cost_at_destination(cave, current_node, destination)
      if lowest_cost do
        {:halt, lowest_cost}
      else
        {:cont, {cave, nodelist}}
      end
    end)
  end

  # Traverse the whole q, removing all closed nodes, and choosing the
  # lowest-cost one as the current. Manhattan distance breaks ties
  # (among equals, choose closest to target).
  #
  defp find_current_node(cave, nodelist, {dest, _destways}) do
    nodelist
    |> Enum.reduce({[], nil, 1_000_000_000, 1_000_000_000}, fn ({{pos, r}, tool}, {node_acc, min_node, min_cost, min_hattan}) ->
      case {Map.get(cave.path_cost, {pos, r}), manhattan(pos, dest)} do
        {nil, _man_hattan} ->
          raise "node on nodelist but not in path_cost?!"  # shouldn't happen
        ###
        # discard closed nodes
        {{_cost, true}, _man_hattan} ->
          {node_acc, min_node, min_cost, min_hattan}
        ###
        # keep unclosed nodes: new min_node (better cost)
        {{cost, false}, man_hattan} when cost < min_cost ->
          {[{{pos, r}, tool} | node_acc], {{pos, r}, tool}, cost, man_hattan}
        ###
        # keep unclosed nodes: new min_node (cost tied, closer Manhattan)
        {{cost, false}, man_hattan} when (cost == min_cost) and (man_hattan < min_hattan) ->
          {[{{pos, r}, tool} | node_acc], {{pos, r}, tool}, cost, man_hattan}
        ###
        # keep unclosed nodes
        {{cost, false}, _man_hattan} when cost >= min_cost ->
          {[{{pos, r}, tool} | node_acc], min_node, min_cost, min_hattan}
      end
    end)
  end

  # Iterate current node's neighbors, updating their costs in the path cost
  # map, and adding neighbors to the queue iff there was no entry in the
  # cost map (newly seen node).
  #
  defp visit_neighbors(cave, nodelist, {{{y, x}, _r}, tool}, cost) do
    # FIXME DRY
    neighbor_positions = [{y-1, x}, {y, x-1}, {y, x+1}, {y+1, x}]
    neighbor_positions
    |> Enum.reduce({cave, nodelist}, fn (n_pos, {cave, node_acc}) ->
      # NB  region of current_node  becomes:  "from" region of neighbor
      region = region_type(cave, {y, x})
      {new_n_cost, new_n_tool} = neighbor_move_cost(cave, cost, tool, region, n_pos)
      #IO.inspect({{n_pos, region}, :n_cost, new_n_cost, new_n_tool}, label: " - visiting neighbor")
      old_path_value = Map.get(cave.path_cost, {n_pos, region})
      case {new_n_cost, old_path_value} do
        ###
        # can't visit inaccessible neighbors
        {nil, _} ->
          {cave, node_acc}
        ###
        # new neighbor: set initial path_cost, add to nodelist
        {_, nil} ->
          new_path_cost = Map.put(cave.path_cost, {n_pos, region}, {new_n_cost, false})
          cave = %{cave | path_cost: new_path_cost}
          {cave, [{{n_pos, region}, new_n_tool} | node_acc]}
        ###
        # don't visit closed neighbors
        {_, {_cost, true}} ->
          {cave, node_acc}
        ###
        # unclosed neighbor, lower cost: update path_cost
        {nucost, {cost, false}} when nucost < cost ->
          new_path_cost = Map.put(cave.path_cost, {n_pos, region}, {nucost, false})
          cave = %{cave | path_cost: new_path_cost}
          {cave, node_acc}
        ###
        # unclosed neighbor: keep existing path_cost
        {nucost, {cost, false}} when nucost >= cost ->
          {cave, node_acc}
      end
    end)
  end

  # Then close the current node, leaving the q alone; closed will be removed
  # on next pass.
  #
  defp close_current_node(cave, {{pos, r}, tool}, cost, {dest, _destways}) do
    # per puzzle requirements, must switch to torch when reaching target
    switch_cost =
      if (pos == dest) && (tool != :torch) do
        @tool_switch_cost
      else
        0
      end
    #IO.inspect({{pos, r}, :cost, cost, :switch, switch_cost}, label: "closing current_node")
    new_path_cost = Map.put(cave.path_cost, {pos, r}, {cost + switch_cost, true})
    %{cave | path_cost: new_path_cost}
  end

  # Finally, determine if the target has been reached: keys must exist in
  # the path cost map for all region types entering the target for us to
  # be considered done. (The first arrival is not necessarily the best.)
  #
  defp cost_at_destination(cave, {node_key, tool}, destination) do
    if dest_reached_from_all_ways?(cave, {node_key, tool}, destination) do
      min_cost_to_destination(cave, destination)
    else
      nil
    end
  end

  defp dest_reached_from_all_ways?(_cave, {{{y, x}, _r}, _tool}, {dest, _dest_ways}) when {y, x} != dest do
    false
  end

  defp dest_reached_from_all_ways?(cave, _current_node, {dest, dest_ways}) do
    dest_ways
    |> Enum.all?(fn (way) ->
      case Map.get(cave.path_cost, {dest, way}) do
        nil -> false
        {_, false} -> false
        {_, true} -> true
      end
    end)
  end

  defp min_cost_to_destination(cave, {dest, dest_ways}) do
    dest_ways
    |> Enum.map(fn (way) ->
      Map.get(cave.path_cost, {dest, way})
      #|> IO.inspect(label: "#{inspect({dest, way})} cost + is_closed")
      |> elem(0)
    end)
    |> Enum.min()
    #|> IO.inspect(label: "** reached target #{inspect(dest)} via #{inspect(dest_ways)}, min_cost")
  end

  @doc """
  Compute the Manhattan distance between two points.

  "Take the sum of the absolute values of the differences of the coordinates.
  For example, if x=(a,b) and y=(c,d), the Manhattan distance between x and y is |a−c|+|b−d|."
  <https://math.stackexchange.com/a/139604>

  ## Examples

  iex> Cave.manhattan({2, 2}, {1, 1})
  2

  iex> Cave.manhattan({6, 3}, {5, 7})
  5

  """
  def manhattan({y1, x1}, {y2, x2}) do
    abs(y1 - y2) + abs(x1 - x2)
  end

  ## NEW CODE BELOW

  @doc """
  Is the given tool disallowed at the given location?

  ## Examples

      iex> cave = Cave.new(21, {3, 3}, 1)
      iex> Cave.banned_tool?(cave, {{0, 0}, :torch})
      false
      iex> Cave.banned_tool?(cave, {{0, 0}, :nothing})
      true
  """
  def banned_tool?(cave, {pos, tool}) do
    region = region_type(cave, pos)
    cond do
      # "you'll likely slip and fall"
      (region == :rocky) && (tool == :nothing) -> true
      # "if it gets wet, you won't have a light source"
      (region == :wet) && (tool == :torch) -> true
      # "it's too bulky to fit"
      (region == :narrow) && (tool == :gear) -> true
      # otherwise OK
      true -> false
    end
  end

  @doc """
  Is the given location "solid rock" (impassable)?

  ## Examples

      iex> cave = Cave.new(21, {3, 3}, 0)
      iex> Cave.solid_rock?(cave, {0, -1})
      true
      iex> Cave.solid_rock?(cave, {3, 3})
      false
      iex> Cave.solid_rock?(cave, {4, 3})
      true
  """
  def solid_rock?(cave, {y, x}) do
    cond do
      (y < 0) || (y > elem(cave.bounds, 0)) -> true
      (x < 0) || (x > elem(cave.bounds, 1)) -> true
      true -> false
    end
  end

  @doc """
  Find cost to change to neighboring location.
  """
  # FIXME rename to neighbor_move_cost() and remove the other one
  def new_move_cost(cave, {{y, x}, tool}, {{ny, nx}, ntool}) do
    cond do
      solid_rock?(cave, {ny, nx}) ->
        nil  # infinite cost
      banned_tool?(cave, {{ny, nx}, ntool}) ->
        nil  # infinite cost
      (y == ny) && (x == nx) && (tool != ntool) ->
        7
      (y == ny) && (x != nx) && (tool == ntool) ->
        1
      (y != ny) && (x == nx) && (tool == ntool) ->
        1
      ###
      # either changed nothing, or changed more than one thing
      true ->
        raise ArgumentError, "bad move #{inspect({{y, x}, tool})} to #{inspect({{ny, nx}, ntool})}"
    end
  end
end
