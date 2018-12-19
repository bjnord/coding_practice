defmodule Reservoir.Flow do
  @type position() :: {y :: non_neg_integer(), x :: non_neg_integer()}

  @doc ~S"""
  Parse the clay veins found in the puzzle input.

  ## Returns

  A grid map describing what's underground.

  ## Example

  # ..+..
  # #....
  # #.###
  # #....

      iex> earth = Reservoir.Flow.parse_clay_input([
      ...>   "x=498, y=1..3\n",
      ...>   "y=2, x=500..502\n",
      ...> ])
      iex> earth
      %{
        {1, 497} => :sand, {1, 498} => :clay, {1, 499} => :sand, {1, 500} => :sand,
                           {1, 501} => :sand, {1, 502} => :sand, {1, 503} => :sand,
        {2, 497} => :sand, {2, 498} => :clay, {2, 499} => :sand, {2, 500} => :clay,
                           {2, 501} => :clay, {2, 502} => :clay, {2, 503} => :sand,
        {3, 497} => :sand, {3, 498} => :clay, {3, 499} => :sand, {3, 500} => :sand,
                           {3, 501} => :sand, {3, 502} => :sand, {3, 503} => :sand,
      }
  """
  @spec parse_clay_input([String.t()]) :: [tuple()]
  def parse_clay_input(lines) when is_list(lines) do
    earth =
      lines
      |> Enum.reduce(MapSet.new(), fn (line, clay) ->
        parse_line(line)
        |> Enum.reduce(clay, fn (pos, clay) -> MapSet.put(clay, pos) end)
      end)
      |> Enum.reduce(%{}, fn (pos, earth) ->
        Map.put(earth, pos, :clay)
      end)
    {min_y, min_x, max_y, max_x} = min_max_of_earth(earth)
    sand_positions =
      for y <- min_y..max_y,
        x <- (min_x-1)..(max_x+1),
        !earth[{y, x}],
        do: {y, x}
    sand_positions
    |> Enum.reduce(earth, fn (pos, earth) -> Map.put(earth, pos, :sand) end)
  end

  defp parse_line(line) when is_binary(line) do
    vert = Regex.run(~r/x=(\d+), y=(\d+)..(\d+)/, line)
    horiz = Regex.run(~r/y=(\d+), x=(\d+)..(\d+)/, line)
    cond do
      vert ->
        [_, x, min_y, max_y] = vert
        String.to_integer(min_y)..String.to_integer(max_y)
        |> Enum.map(&({&1, String.to_integer(x)}))
      horiz ->
        [_, y, min_x, max_x] = horiz
        String.to_integer(min_x)..String.to_integer(max_x)
        |> Enum.map(&({String.to_integer(y), &1}))
    end
  end

  def debug_step_dump(earth, where, pos) do
    if Application.get_env(:reservoir, :debug_steps) do
      IO.puts("")
      IO.puts(where)
      dump_earth(earth, center: pos)
      IO.write("continue> ")
      IO.read(:stdio, :line)
    else
      {earth, where, pos}  # suppress warning
    end
  end

  def dump_earth(earth, opts \\ []) do
    {y, _x} = if opts[:center], do: opts[:center], else: {1, 500}
    {min_y, min_x, max_y, max_x} = min_max_of_earth(earth)
    x_range = min_x..max_x
    y_range =  # restrict to 45-line "window" unless "full: true"
      cond do
        opts[:full] ->
          min_y..max_y
        (max_y - min_y) <= 44 ->
          min_y..max_y
        y > 22 && y < (max_y-22) ->
          (y-22)..(y+22)
        y > 22 ->
          (max_y-44)..max_y
        true ->
          min_y..(min_y+44)
      end
    dump_x_header(x_range)
    #dump_spring_line(x_range)
    y_range
    |> Enum.map(fn (y) -> dump_earth_line(earth, y, x_range) end)
    earth
  end

  defp min_max_of_earth(earth) do
    {_min_y, max_y} =
      Enum.map(earth, &(elem(elem(&1, 0), 0)))
      |> Enum.min_max()
    {min_x, max_x} =
      Enum.map(earth, &(elem(elem(&1, 0), 1)))
      |> Enum.min_max()
    # min_y must always be 1 (so flow from {0, 500} will work)
    # even though the count functions may exclude those rows
    {1, min_x, max_y, max_x}
  end

#  defp dump_spring_line(x_range) do
#    IO.write("      ")
#    x_range
#    |> Enum.map(&(emit_spring_square(&1)))
#    IO.write("\n")
#  end

  # FIXME call defp subfunction with function pointer to do div/rem math
  defp dump_x_header(x_range) do
    IO.write("      ")
    x_range
    |> Enum.map(fn (x) ->
      h = if x == 500, do: '+', else: rem(div(x, 100), 10)
      IO.write(h)
    end)
    IO.write("\n")
    IO.write("      ")
    x_range
    |> Enum.map(fn (x) ->
      h = if x == 500, do: '+', else: rem(div(x, 10), 10)
      IO.write(h)
    end)
    IO.write("\n")
    IO.write("      ")
    x_range
    |> Enum.map(fn (x) ->
      h = if x == 500, do: '+', else: rem(x, 10)
      IO.write(h)
    end)
    IO.write("\n")
  end

#  defp emit_spring_square(x) do
#    if x == 500 do
#      '+'  # :spring
#    else
#      '.'  # :sand
#    end
#    |> IO.write
#  end

  defp dump_earth_line(earth, y, x_range) do
    IO.write(String.pad_leading(Integer.to_string(y), 5))
    IO.write(" ")
    x_range
    |> Enum.map(&(IO.write(earth_char(earth, {y, &1}))))
    IO.write("\n")
  end

  defp earth_char(earth, pos) do
    case earth[pos] do
      :sand -> '.'
      :clay -> '#'
      :flow -> '|'
      :water -> '~'
    end
  end

  @doc ~S"""
  Simulate water flow from the spring.

  ## Returns

  Updated map with squares filled with water/flow
  """
  @spec flow(map()) :: map()
  def flow(earth) when is_map(earth) do
    debug_step_dump(earth, "before initial flow()", {1, 500})
    earth = flow_down(earth, {0, 500})
    debug_step_dump(earth, "end of flow()", {1, 500})
    earth
  end

  # NB this is the only recursive call, and the main work-horse
  @spec flow_down(map(), position()) :: map()
  defp flow_down(earth, {orig_y, orig_x}) do
    ###
    # first do my own downward-flowing as far as I can:
    {earth, {y, x}, state} =
      1..1_000_000
      |> Enum.reduce_while({earth, {orig_y, orig_x}, :flowing}, fn (_n, {earth, {j, i}, _state}) ->
        j = j + 1
        case earth[{j, i}] do
          :sand ->
            {:cont, {Map.replace!(earth, {j, i}, :flow), {j, i}, :flowing}}
          :clay ->
            {:halt, {earth, {j-1, i}, :v_blocked}}
          :flow ->
            {:cont, {earth, {j, i}, :flowing}}
          :water ->
            {:halt, {earth, {j-1, i}, :v_blocked}}
          :nil ->
            {:halt, {earth, {j, i}, :off_bottom}}
        end
      end)
    ###
    # then evaluate what happened, and make calls needed to continue flow
    # (may call self recursively)
    case state do
      :v_blocked ->  # hit something that stopped downward flow
        # extend :flow area left and right, as far as possible
        earth = flow_self(earth, {y, x})
        debug_step_dump(earth, "before {#{y}, #{x}} flow_sides(-1)", {y, x})
        {earth, l_pos, l_state} = flow_sides(earth, {y, x}, -1)
        debug_step_dump(earth, "before {#{y}, #{x}} flow_sides(+1)", {y, x})
        {earth, r_pos, r_state} = flow_sides(earth, {y, x}, +1)
        cond do
          ###
          # this is a "cup" row (blocked at both ends)
          # fill :flow areas with :water
          l_state == :h_blocked && r_state == :h_blocked ->
            debug_step_dump(earth, "before {#{y}, #{x}} fill_sides(self, -1, +1)", {y, x})
            earth = Map.replace!(earth, {y, x}, :water)
            earth = fill_sides(earth, {y, x}, -1)
            earth = fill_sides(earth, {y, x}, +1)
            if y-1 < 0 do
              earth  # water rose to top line; done
            else
              debug_step_dump(earth, "before {#{y-1}, #{x}} flow_down() above", {y-1, x})
              flow_down(earth, {y-1, x})
            end
          ###
          # here, one side could be :flowed_hole | :h_blocked | :off_edge
          # in all 3 cases we can ignore that side, and just flow the :hole side
          l_state == :hole || r_state == :hole ->
            earth =
              if l_state == :hole do
                {ly, lx} = l_pos
                debug_step_dump(earth, "before {#{ly}, #{lx}} flow_down() left-hole", {ly, lx})
                flow_down(earth, l_pos)
              else
                earth
              end
            earth =
              # FIXME is the water check still needed? conversely, is it also needed for left?
              if r_state == :hole && earth[r_pos] != :water do
                {ry, rx} = r_pos
                debug_step_dump(earth, "before {#{ry}, #{rx}} flow_down() right-hole", {ry, rx})
                flow_down(earth, r_pos)
              else
                earth
              end
            earth  # recursion has finished the rest; done
          ###
          # here, both sides are either :flowed_hole | :h_blocked | :off_edge
          # in all these cases, it means we're done
          l_state in [:flowed_hole, :h_blocked, :off_edge] && r_state in [:flowed_hole, :h_blocked, :off_edge] ->
            earth
        end
      :off_bottom ->  # this stream flowed off bottom edge; done
        earth
    end
  end

  defp flow_self(earth, {y, x}) do
    if earth[{y, x}] == :sand do
      Map.replace!(earth, {y, x}, :flow)
    else
      earth
    end
  end

  # returns earth / pos / state = <:hole | :flowed_hole | :h_blocked | :off_edge>
  defp flow_sides(earth, {y, x}, x_inc) do
    1..1_000_000
    |> Enum.reduce_while({earth, {y, x}, :flowing}, fn (_n, {earth, {j, i}, _state}) ->
      i = i + x_inc
      case earth[{j, i}] do
        :sand ->
          case earth[{j+1, i}] do
            :sand ->   # unflowed hole below us
              {:halt, {Map.replace!(earth, {j, i}, :flow), {j, i}, :hole}}
            :flow ->   # already-flowed hole below us
              {:halt, {Map.replace!(earth, {j, i}, :flow), {j, i}, :flowed_hole}}
            _ ->
              {:cont, {Map.replace!(earth, {j, i}, :flow), {j, i}, :flowing}}
          end
        :clay ->
          {:halt, {earth, {j, i}, :h_blocked}}
        :flow ->
          case earth[{j+1, i}] do
            :sand ->   # unflowed hole below us
              {:halt, {earth, {j, i}, :hole}}
            :flow ->   # already-flowed hole below us
              {:halt, {earth, {j, i}, :flowed_hole}}
            _ ->
              {:cont, {earth, {j, i}, :flowing}}
          end
        :nil ->
          {:halt, {earth, {j, i}, :off_edge}}
      end
    end)
  end

  # returns earth
  defp fill_sides(earth, {y, x}, x_inc) do
    1..1_000_000
    |> Enum.reduce_while({earth, {y, x}, :filling}, fn (_n, {earth, {j, i}, _state}) ->
      i = i + x_inc
      case earth[{j, i}] do
        :sand ->
          {:cont, {Map.replace!(earth, {j, i}, :water), {j, i}, :filling}}
        :clay ->
          {:halt, {earth, {j, i}, :h_blocked}}
        :flow ->
          {:cont, {Map.replace!(earth, {j, i}, :water), {j, i}, :filling}}
      end
    end)
    |> elem(0)
  end

  @doc ~S"""
  Count number of squares of the given type(s)
  """
  def water_count(earth, kind) do
    # Puzzle: "To prevent counting forever, ignore tiles with a y
    # coordinate smaller than the smallest y coordinate in your scan
    # data" - Thus, even though water has to flow through y=1 etc.
    # to get anywhere, we don't count squares in those rows.
    min_y = Map.keys(earth)
            |> Enum.filter(&(earth[&1] == :clay))
            |> Enum.min_by(&(elem(&1, 0)))
            |> elem(0)
    Map.keys(earth)
    |> Enum.reduce(0, fn ({y, x}, acc) ->
      cond do
        y < min_y ->
          acc
        earth[{y, x}] in kind ->
          acc + 1
        true ->
          acc
      end
    end)
  end
end
