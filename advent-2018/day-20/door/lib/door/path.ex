defmodule Door.Path do
  @doc ~S"""
  Walks the tree, finding the shortest paths to all rooms.

  The paths are returned backwards (to make building the path more efficient):

  - To move from a room back to the origin, using the steps as provided, you
  would need to flip all the directions (`:w <=> :e` and `:n <=> :s`).

  - To move from the origin to a room, using the steps as provided, you
  would need to reverse the list of steps (start from the end).

  ## Returns

  List of room locations, each with the shortest path to it **in reverse order**

  ## Examples

      iex> Door.Path.reversed_shortest_paths(%{0 => []})
      %{
        {0, 0} => [],
      }

      iex> Door.Path.reversed_shortest_paths(%{0 => [:w, :n, :e]})
      %{
        {0, 0} => [],
        {0, -1} => [:w],  # 0
        {-1, -1} => [:n, :w],
        {-1, 0} => [:e, :n, :w],
      }

      iex> Door.Path.reversed_shortest_paths(%{
      ...>   0 => [:w, :n, :e, :e],
      ...>   ?A => %{0 => [:s]},
      ...>   ?B => %{0 => [:e, :s]},
      ...>   1 => %{0 => [:n, :w, :w]},
      ...> })
      %{
        {0, 0} => [],
        {0, -1} => [:w],  # 0
        {-1, -1} => [:n, :w],
        {-1, 0} => [:e, :n, :w],
        {-1, 1} => [:e, :e, :n, :w],
        {0, 1} => [:s, :e, :e, :n, :w],  # ?A
        {-1, 2} => [:e, :e, :e, :n, :w],  # ?B
        {0, 2} => [:s, :e, :e, :e, :n, :w],
        {-2, 1} => [:n, :e, :e, :n, :w],  # 1
        {-2, 0} => [:w, :n, :e, :e, :n, :w],
        {-2, -1} => [:w, :w, :n, :e, :e, :n, :w],
      }
  """

#     iex> Door.Path.reversed_shortest_paths(%{
#     ...>   0 => [:w],
#     ...>   ?A => %{0 => [:n]},
#     ...>   ?B => %{
#     ...>     0 => [:e],
#     ...>     ?A => %{0 => [:s, :e]},
#     ...>     ?B => %{0 => [:s, :w]},
#     ...>     1 => %{0 => [:w]},
#     ...>   },
#     ...>   1 => %{0 => [:e]},
#     ...> }
#     %{
#       ...
#     }

  @spec reversed_shortest_paths(map) :: map()
  def reversed_shortest_paths(tree) do
    paths = %{{0, 0} => []}
    walk_node(tree, paths, [], {0, 0})
  end

  # returns updated paths (map)
  defp walk_node(tree, paths, steps, origin) do
    ###
    # first take the steps in our key 0 list
    # (this moves origin / adds steps for subsequent calls)
    {paths, steps, origin} =
      walk_steps(Map.get(tree, 0), paths, steps, origin)
    ###
    # then walk our child trees [side branches]
    # (origin stays here)
    paths =
      Map.keys(tree)
      |> Enum.reject(&(&1 == 0 || &1 == 1))
      #|> IO.inspect(label: "children keys")
      |> Enum.reduce(paths, fn (key, paths) ->
        child = Map.get(tree, key)
                #|> IO.inspect(label: "my child #{key}")
        walk_node(child, paths, steps, origin)
      end)
    ###
    # finally walk our key 1 node, if any [main branch]
    tree_1 = Map.get(tree, 1)
    if tree_1 do
      walk_node(tree_1, paths, steps, origin)  # tail recursion
    else
      paths
    end
  end

  # returns updated {paths, steps, room_pos}
  defp walk_steps(tree_steps, paths, steps, origin) do
    tree_steps
    #|> IO.inspect(label: "my 0-list")
    |> Enum.reduce({paths, steps, origin}, fn (dir, {paths, steps, room_pos}) ->
      steps = [dir | steps]
      room_pos = move_yx(room_pos, dir)
      if Map.has_key?(paths, room_pos) do
        # FIXME OPTIMIZE should probably store step count in map
        map_len = Enum.count(Map.get(paths, room_pos))
        steps_len = Enum.count(steps)
        if steps_len < map_len do
          raise "found a shorter path"
        end
        {paths, steps, room_pos}
      else
        {Map.put(paths, room_pos, steps), steps, room_pos}
      end
    end)
  end

  defp move_yx({y, x}, dir) do
    case dir do
      :n -> {y-1, x}
      :s -> {y+1, x}
      :e -> {y, x+1}
      :w -> {y, x-1}
    end
  end
end
