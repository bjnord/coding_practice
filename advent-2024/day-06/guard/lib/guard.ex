defmodule Guard do
  @moduledoc """
  Documentation for `Guard`.
  """

  import Guard.Parser
  import History.CLI
  alias History.Grid
  require Logger

  def squares_walked(grid) do
    {visited, _, _} = walk(grid, start_pos(grid), {{-1, 0}, %{}}, {%{}, [], true})
    if visited == :loop do
      :loop
    else
      Map.keys(visited)
      |> Enum.count()
    end
  end

  defp start_pos(grid) do
    Grid.keys(grid)
    |> Enum.find(fn pos -> Grid.get(grid, pos) == ?^ end)
  end

  # the third argument is our "turn state", a tuple containing:
  # - current facing direction, as a delta `{dy, dx}`
  # - list of `{y, x}` locations where we've previously turned
  #
  # when we detect a loop (a "box" in which we just turned 4 times
  # and ended up in the same spot) it gets replaced with `:loop`
  # to terminate the walk
  #
  # the fourth argument is an accumulator (see `accumulate/4` below)
  #
  # the function returns a tuple with
  # - unique squares visited (map), or `:loop`
  # - list of potential obstacle locations (`{y, x}` tuples)
  # - polopos flag (boolean)
  #
  defp walk(_grid, _pos, :loop, _acc), do: {:loop, [], nil}
  defp walk(grid, {y, x}, {{dy, dx}, turns}, acc) do
    ny = y + dy
    nx = x + dx
    cond do
      !Grid.in_bounds?(grid, {ny, nx}) ->
        # walked off edge; done
        if debug(), do: debug_dump(mark(grid, {y, x}))
        accumulate(grid, {y, x}, {ny, nx}, acc)
      Grid.get(grid, {ny, nx}) == ?# ->
        # turn but don't move
        if debug(), do: debug_dump(mark(grid, {y, x}))
        walk(grid, {y, x}, turn({{dy, dx}, turns}, {y, x}), acc)
      true ->
        # move one square forward
        walk(mark(grid, {y, x}), {ny, nx}, {{dy, dx}, turns}, accumulate(grid, {y, x}, {ny, nx}, acc))
    end
  end

  defp mark(grid, pos) do
    Grid.get_and_update(grid, pos, &({&1, ?X}))
  end

  # when walking forward, only count squares we haven't walked before
  #
  # `pos` is the square we're **leaving** as we walk forward
  # `next_pos` is the square we're **entering**
  #
  # the accumulator is a tuple containing:
  # - map of visited squares
  # - list of potential loop-producing obstacle locations
  # - whether to build the polops list
  defp accumulate(grid, pos, next_pos, {visited, polopos, build}) do
    case Grid.get(grid, pos) do
      ?X ->
        # we crossed a square we've walked before; the square we're moving
        # into is a potential spot to drop an obstacle that produces a loop
        if build do
          {visited, [next_pos | polopos], build}
        else
          {visited, polopos, build}
        end
      _  ->
        # we haven't walked this square yet; mark as visited
        if build && turn_hits_obstacle?(grid, pos, next_pos) do
          # ...and also note potential obstacle spot
          {Map.put(visited, pos, true), [next_pos | polopos], build}
        else
          {Map.put(visited, pos, true), polopos, build}
        end
    end
  end

  defp turn_hits_obstacle?(grid, {y, x}, {ny, nx}) do
    dir = {ny - y, nx - x}
    {dy, dx} = turn({dir, %{}}, {y, x})
               |> elem(0)
    Logger.debug("turn_hits_obstacle start: pos #{y},#{x} next_pos #{ny},#{nx} new_dir #{dy},#{dx}")
    Stream.cycle([true])
    |> Enum.reduce_while({y, x}, fn _, {hy, hx} ->
      ret =
        cond do
          !Grid.in_bounds?(grid, {hy, hx}) ->
            # walked off edge
            {:halt, false}
          Grid.get(grid, {hy, hx}) == ?# ->
            # hit obstacle
            {:halt, true}
          true ->
            {:cont, {hy + dy, hx + dx}}
        end
      Logger.debug("turn_hits_obstacle step: #{hy},#{hx} #{inspect(ret)}")
      ret
    end)
  end

  defp debug(), do: !!System.get_env("DEBUG")

  defp debug_dump(grid) do
    0..(grid.size.y - 1)
    |> Enum.map(&(debug_dump_line(grid, &1)))
    Logger.debug("")
  end

  defp debug_dump_line(grid, y) do
    0..(grid.size.x - 1)
    |> Enum.map(&(Grid.get(grid, {y, &1})))
    |> Enum.map(&debug_dump_char/1)
    |> Logger.debug()
  end

  defp debug_dump_char(ch) do
    case ch do
      ?#  -> ?#
      ?^  -> ?X
      ?X  -> ?X
      _   -> ?.
    end
  end

  # 90-degree right turn, accumulating previous turn locations
  defp turn({dir, turns}, pos) do
    # detect looping (return to same spot, facing same direction)
    if Map.has_key?(turns, {pos, dir}) do
      :loop
    else
      case dir do
        {-1, 0} -> {{0, 1},  Map.put(turns, {pos, dir}, true)}
        {0, 1}  -> {{1, 0},  Map.put(turns, {pos, dir}, true)}
        {1, 0}  -> {{0, -1}, Map.put(turns, {pos, dir}, true)}
        {0, -1} -> {{-1, 0}, Map.put(turns, {pos, dir}, true)}
      end
    end
  end

  def brute_loop_obstacles(grid) do
    for y <- 0..(grid.size.y - 1),
        x <- 0..(grid.size.x - 1) do
      grid =
        Grid.get_and_update(grid, {y, x}, fn ch ->
          case ch do
            ?^ -> {ch, ch}
            _  -> {ch, ?#}
          end
        end)
      if elem(walk(grid, start_pos(grid), {{-1, 0}, %{}}, {%{}, [], false}), 0) == :loop do
        {y, x}
      else
        :noloop
      end
    end
    |> Enum.reject(&(&1 == :noloop))
  end

  def loop_obstacles(grid) do
    potential_loop_obstacles(grid)
    |> Enum.filter(fn {y, x} ->
      grid =
        Grid.get_and_update(grid, {y, x}, fn ch ->
          case ch do
            ?^ -> {ch, ch}
            _  -> {ch, ?#}
          end
        end)
      elem(walk(grid, start_pos(grid), {{-1, 0}, %{}}, {%{}, [], false}), 0) == :loop
    end)
  end

  defp potential_loop_obstacles(grid) do
    walk(grid, start_pos(grid), {{-1, 0}, %{}}, {%{}, [], true})
    |> elem(1)
    |> Enum.uniq()  # FIXME necessary?
  end

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Guard.squares_walked()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Guard.loop_obstacles()
    |> Enum.count()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
