defmodule Beam.Contraption do
  @moduledoc """
  Contraption structure and functions for `Beam`.
  """

  defstruct tiles: %{}, size: {0, 0}

  require Logger
  alias Beam.Contraption

  @doc ~S"""
  Form a `Contraption` from a list of mirror/splitter tiles.

  ## Parameters

  - `tile_list` - a list of `{{y, x}, ch}` tiles

  Returns a `Contraption`.
  """
  def from_tiles(tile_list) do
    tiles = Enum.into(tile_list, %{})
    %Contraption{
      tiles: tiles,
      size: dimensions(tiles),
    }
  end

  # FIXME this could fail if last row/column is all `?.`
  defp dimensions(tiles) do
    positions = Map.keys(tiles)
    {
      elem(Enum.max_by(positions, fn {y, _x} -> y end), 0) + 1,
      elem(Enum.max_by(positions, fn {_y, x} -> x end), 1) + 1,
    }
  end

  @doc ~S"""
  Calculate the number of energized tiles in a `Contraption`.

  ## Parameters

  - `contraption` - the `Contraption`

  Returns the number of energized tiles (integer).
  """
  def n_energized(contraption) do
    travel(contraption)
    |> Enum.count()
  end

  @doc ~S"""
  Find the tiles traversed by the beam moving through a `Contraption`.

  ## Parameters

  - `contraption` - the `Contraption`

  Returns the list of tiles traversed (`{y, x}` tuples).
  """
  def travel(contraption) when not is_tuple(contraption) do
    # "The beam enters in the top-left corner from the left and heading
    # to the right."
    initial_q = [{{0, 0}, :east}]
    # path accumulator map: key = segment `{pos, dir}` / value = path `[pos, ...]`
    Stream.cycle([true])
    |> Enum.reduce_while({initial_q, %{}}, fn _, {segment_q, pathmap} ->
      if segment_q == [] do
        {:halt, pathmap}
      else
        # take next segment from queue
        # TODO could `{pos, dir}` just be `segment`? (ever use `pos` or `dir` separately?)
        [{pos, dir} | rem_q] = segment_q
        if pathmap[{pos, dir}] do
          # already followed this segment
          {:cont, {rem_q, pathmap}}
        else
          # follow segment to end, obtaining path + next segments (if any)
          {path, {next_pos, next_dirs}} = segment({pos, dir}, [], contraption)
          # add segment to accumulator
          # TODO could this use `%{pathmap | {pos, dir} => path}` notation?
          pathmap = Map.put(pathmap, {pos, dir}, path)
          # put next segments (if any) onto queue
          case next_dirs do
            :east_west ->
              {:cont, {[{next_pos, :east}, {next_pos, :west} | rem_q], pathmap}}
            :north_south ->
              {:cont, {[{next_pos, :north}, {next_pos, :south} | rem_q], pathmap}}
            nil ->
              {:cont, {rem_q, pathmap}}
            _ ->
              raise "invalid next_dirs #{next_dirs}"
          end
        end
      end
    end)
    |> Enum.reduce([], fn {_pos, path}, positions ->
      # OPTIMIZE could reverse-fold
      positions ++ path
    end)
    |> Enum.uniq()
  end

  # returns `{path, {next_pos, next_dirs}}`
  # "Then, its behavior depends on what it encounters as it moves:"
  defp segment({pos, dir}, path, contraption) do
    tile = Map.get(contraption.tiles, pos, ?.)
    #label = "tile #{<<tile::utf8>>} pos #{inspect(pos)} dir #{dir}"
    #dump(contraption, label: label, cur_pos: pos)
    cond do
      # - (If the beam goes out of bounds, stop travelling.)
      out_of_bounds?(pos, contraption) ->
        {path, {nil, nil}}
      # - If the beam encounters *empty space* (`.`), it continues in the
      #   same direction.
      tile == ?. ->
        segment({next_pos(pos, dir), dir}, [pos | path], contraption)
      # - If the beam encounters a *mirror* (`/` or `\`), the beam is
      #   *reflected* 90 degrees depending on the angle of the mirror.
      tile == ?/ && dir == :east ->
        segment({next_pos(pos, :north), :north}, [pos | path], contraption)
      tile == ?/ && dir == :north ->
        segment({next_pos(pos, :east), :east}, [pos | path], contraption)
      tile == ?/ && dir == :west ->
        segment({next_pos(pos, :south), :south}, [pos | path], contraption)
      tile == ?/ && dir == :south ->
        segment({next_pos(pos, :west), :west}, [pos | path], contraption)
      tile == ?\\ && dir == :east ->
        segment({next_pos(pos, :south), :south}, [pos | path], contraption)
      tile == ?\\ && dir == :south ->
        segment({next_pos(pos, :east), :east}, [pos | path], contraption)
      tile == ?\\ && dir == :west ->
        segment({next_pos(pos, :north), :north}, [pos | path], contraption)
      tile == ?\\ && dir == :north ->
        segment({next_pos(pos, :west), :west}, [pos | path], contraption)
      # - If the beam encounters the *pointy end of a splitter* (`|` or `-`),
      #   the beam passes through the splitter as if the splitter were *empty
      #   space*.
      tile == ?| && north_south?(dir) ->
        segment({next_pos(pos, dir), dir}, [pos | path], contraption)
      tile == ?- && east_west?(dir) ->
        segment({next_pos(pos, dir), dir}, [pos | path], contraption)
      # - If the beam encounters the *flat side of a splitter* (`|` or `-`),
      #   the beam is *split into two beams* going in each of the two
      #   directions the splitter's pointy ends are pointing.
      tile == ?| && east_west?(dir) ->
        {path, {pos, :north_south}}
      tile == ?- && north_south?(dir) ->
        {path, {pos, :east_west}}
      true ->
        raise "unimplemented tile=#{<<tile::utf8>>} pos=#{inspect(pos)} dir=#{dir}"
    end
  end

  defp next_pos({y, x}, dir) do
    case dir do
      :north -> {y - 1, x}
      :south -> {y + 1, x}
      :east  -> {y, x + 1}
      :west  -> {y, x - 1}
      _      -> raise "invalid dir #{dir}"
    end
  end

  defp out_of_bounds?({y, x}, contraption) do
    {height, width} = contraption.size
    cond do
      y < 0       -> true
      y >= height -> true
      x < 0       -> true
      x >= width  -> true
      true        -> false
    end
  end

  defp east_west?(dir) when dir == :east, do: true
  defp east_west?(dir) when dir == :west, do: true
  defp east_west?(_dir), do: false

  defp north_south?(dir) when dir == :north, do: true
  defp north_south?(dir) when dir == :south, do: true
  defp north_south?(_dir), do: false

  def dump(contraption, opts \\ []) do
    {height, width} = contraption.size
    if opts[:label] do
      IO.puts("-- [#{opts[:label]}] --")
    else
      IO.puts("-- #{height} x #{width} ------------------")
    end
    for y <- 0..(height-1), do: dump_row(contraption, y, width, opts)
    IO.puts("")
  end

  defp dump_row(contraption, y, width, opts) do
    line =
      0..(width-1)
      |> Enum.reduce([], fn x, line ->
        [tile_at(contraption, y, x, opts) | line]
      end)
      |> Enum.reverse()
      |> List.to_string()
    IO.puts(line)
  end

  defp tile_at(contraption, y, x, opts) do
    if opts[:cur_pos] do
      {cur_y, cur_x} = opts[:cur_pos]
      if (y == cur_y) && (x == cur_x) do
        ?*
      else
        Map.get(contraption.tiles, {y, x}, ?.)
      end
    else
      Map.get(contraption.tiles, {y, x}, ?.)
    end
  end
end
