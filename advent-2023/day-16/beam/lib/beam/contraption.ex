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
    step({{0, 0}, :east}, {%{}, %{}}, contraption)
    |> then(fn {sp_seen, obj_seen} ->
      Map.keys(obj_seen)
      |> Enum.reduce(Map.keys(sp_seen), fn {pos, _dir}, acc -> [pos | acc] end)
    end)
    |> Enum.uniq()
  end

  # returns `{sp_seen, obj_seen}` accumulator
  defp step(step, step_acc, contraption) do
    next_steps(step, step_acc, contraption)
    |> Enum.map(fn {next_step, step_acc} ->
      if next_step do
        step(next_step, step_acc, contraption)
      else
        step_acc
      end
    end)
    |> List.flatten()
    |> Enum.reduce({%{}, %{}}, fn {sp_seen, obj_seen}, {sp_acc, obj_acc} ->
      {
        Enum.reduce(Map.keys(sp_seen), sp_acc, fn sp, acc -> Map.put(acc, sp, true) end),
        Enum.reduce(Map.keys(obj_seen), obj_acc, fn obj, acc -> Map.put(acc, obj, true) end),
      }
    end)
  end

  # returns list of `{next_step, step_acc}`
  # "Then, its behavior depends on what it encounters as it moves:"
  defp next_steps({pos, dir}, {sp_seen, obj_seen}, contraption) do
    tile = Map.get(contraption.tiles, pos, ?.)
    #label = "tile #{<<tile::utf8>>} pos #{inspect(pos)} dir #{dir}"
    #dump(contraption, label: label, cur_pos: pos)
    cond do
      # - (If the beam goes out of bounds, stop travelling.)
      out_of_bounds?(pos, contraption) ->
        [{nil, {sp_seen, obj_seen}}]
      # - (If the beam hits an object we've already seen, while travelling
      #   in this direction, stop travelling.)
      Map.get(obj_seen, {pos, dir}, nil) ->
        [{nil, {sp_seen, obj_seen}}]
      # - If the beam encounters *empty space* (`.`), it continues in the
      #   same direction.
      tile == ?. ->
        new_sp_seen = Map.put(sp_seen, pos, true)
        [{{next_pos(pos, dir), dir}, {new_sp_seen, obj_seen}}]
      # - If the beam encounters a *mirror* (`/` or `\`), the beam is
      #   *reflected* 90 degrees depending on the angle of the mirror.
      tile == ?/ && dir == :east ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, :north), :north}, {sp_seen, new_obj_seen}}]
      tile == ?/ && dir == :north ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, :east), :east}, {sp_seen, new_obj_seen}}]
      tile == ?/ && dir == :west ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, :south), :south}, {sp_seen, new_obj_seen}}]
      tile == ?/ && dir == :south ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, :west), :west}, {sp_seen, new_obj_seen}}]
      tile == ?\\ && dir == :east ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, :south), :south}, {sp_seen, new_obj_seen}}]
      tile == ?\\ && dir == :south ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, :east), :east}, {sp_seen, new_obj_seen}}]
      tile == ?\\ && dir == :west ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, :north), :north}, {sp_seen, new_obj_seen}}]
      tile == ?\\ && dir == :north ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, :west), :west}, {sp_seen, new_obj_seen}}]
      # - If the beam encounters the *pointy end of a splitter* (`|` or `-`),
      #   the beam passes through the splitter as if the splitter were *empty
      #   space*.
      tile == ?| && north_south?(dir) ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, dir), dir}, {sp_seen, new_obj_seen}}]
      tile == ?- && east_west?(dir) ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [{{next_pos(pos, dir), dir}, {sp_seen, new_obj_seen}}]
      # - If the beam encounters the *flat side of a splitter* (`|` or `-`),
      #   the beam is *split into two beams* going in each of the two
      #   directions the splitter's pointy ends are pointing.
      # TODO could also insert into `new_obj_seen` for pass-thru directions
      tile == ?| && east_west?(dir) ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [
          {{next_pos(pos, :north), :north}, {sp_seen, new_obj_seen}},
          {{next_pos(pos, :south), :south}, {sp_seen, new_obj_seen}},
        ]
      tile == ?- && north_south?(dir) ->
        new_obj_seen = Map.put(obj_seen, {pos, dir}, true)
        [
          {{next_pos(pos, :east), :east}, {sp_seen, new_obj_seen}},
          {{next_pos(pos, :west), :west}, {sp_seen, new_obj_seen}},
        ]
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
