defmodule Lanternfish do
  @moduledoc """
  Documentation for `Lanternfish`.
  """

  import Lanternfish.Parser
  import History.CLI
  alias History.Grid

  # NOTE these are returned backwards (final movement = head of list)
  def movements({grid, directions}) do
    directions
    |> Enum.reduce([{grid, grid.meta.start}], fn dir, [{grid0, pos0} | acc] ->
      [move(grid0, pos0, dir), {grid0, pos0} | acc]
    end)
  end

  defp move(grid, pos, dir) do
    next_pos = delta_pos(pos, delta(dir))
    {status, shifts} = box_shifts(grid, {next_pos, Grid.get(grid, next_pos)}, dir, [])
    if status == :clear do
      {shift_boxes(grid, shifts), next_pos}
    else
      {grid, pos}
    end
  end

  # always called with a box/floor/wall `{pos, ch}` (not the robot)
  defp box_shifts(_grid, {_pos, ch}, _dir, _shifts) when ch == ?#, do: {:blocked, []}
  defp box_shifts(_grid, {_pos, ch}, _dir, shifts) when ch == nil, do: {:clear, shifts}
  defp box_shifts(grid, {pos, ch}, dir, shifts) when ch == ?O or dir in [:east, :west] do
    next_pos = delta_pos(pos, delta(dir))
    box_shifts(grid, {next_pos, Grid.get(grid, next_pos)}, dir, [{pos, next_pos, ch} | shifts])
  end
  defp box_shifts(grid, {{y, x}, ch}, dir, shifts) when ch == ?[ do
    {ny, nx} = delta_pos({y, x}, delta(dir))
    {l_status, l_shifts} =
      box_shifts(grid, {{ny, nx}, Grid.get(grid, {ny, nx})}, dir, [{{y, x}, {ny, nx}, ch} | shifts])
    r_ch = ?]
    {r_status, r_shifts} =
      box_shifts(grid, {{ny, nx + 1}, Grid.get(grid, {ny, nx + 1})}, dir, [{{y, x + 1}, {ny, nx + 1}, r_ch} | shifts])
    combine_l_r({l_status, l_shifts}, {r_status, r_shifts}, dir)
  end
  defp box_shifts(grid, {{y, x}, ch}, dir, shifts) when ch == ?] do
    {ny, nx} = delta_pos({y, x}, delta(dir))
    l_ch = ?[
    {l_status, l_shifts} =
      box_shifts(grid, {{ny, nx - 1}, Grid.get(grid, {ny, nx - 1})}, dir, [{{y, x - 1}, {ny, nx - 1}, l_ch} | shifts])
    {r_status, r_shifts} =
      box_shifts(grid, {{ny, nx}, Grid.get(grid, {ny, nx})}, dir, [{{y, x}, {ny, nx}, ch} | shifts])
    combine_l_r({l_status, l_shifts}, {r_status, r_shifts}, dir)
  end

  defp combine_l_r({l_status, _l_shifts}, {_r_status, _r_shifts}, _dir) when l_status == :blocked, do: {:blocked, []}
  defp combine_l_r({_l_status, _l_shifts}, {r_status, _r_shifts}, _dir) when r_status == :blocked, do: {:blocked, []}
  defp combine_l_r({_l_status, l_shifts}, {_r_status, r_shifts}, dir) do
    sorter =
      if dir == :north do
        &(&1 <= &2)
      else
        &(&1 >= &2)
      end
    {
      :clear,
      Enum.uniq(l_shifts ++ r_shifts)
      |> Enum.sort(fn {_, to_left, _}, {_, to_right, _} -> sorter.(to_left, to_right) end)
    }
  end

  defp shift_boxes(grid, []), do: grid
  defp shift_boxes(grid, [{from_pos, to_pos, ch} | rem]) do
    Grid.delete(grid, from_pos)
    |> Grid.put(to_pos, ch)
    |> shift_boxes(rem)
  end

  defp delta(:north), do: {-1, 0}
  defp delta(:east), do: {0, 1}
  defp delta(:south), do: {1, 0}
  defp delta(:west), do: {0, -1}

  defp delta_pos({y, x}, {dy, dx}), do: {y + dy, x + dx}

  def dump_string({grid, {ry, rx}}) do
    0..(grid.size.y - 1)
    |> Enum.map(&(dump_line(grid, &1, {ry, rx})))
    |> Enum.join("\n")
    |> then(fn s -> s <> "\n" end)
  end

  defp dump_line(grid, y, {ry, rx}) do
    0..(grid.size.x - 1)
    |> Enum.map(&(dump_char(grid, {y, &1}, {ry, rx})))
    |> List.to_string()
  end

  defp dump_char(grid, {y, x}, {ry, rx}) do
    ch = Grid.get(grid, {y, x})
    cond do
      (y == ry) && (x == rx) -> ?@
      ch in [?#, ?O, ?[, ?]] -> ch
      true                   -> ?.
    end
  end

  def gps({grid, _pos}) do
    Grid.keys(grid)
    |> Enum.reduce(0, fn {y, x} = pos, acc ->
      case Grid.get(grid, pos) do
        ?O -> y * 100 + x + acc
        ?[ -> y * 100 + x + acc
        _  -> acc
      end
    end)
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
    |> Lanternfish.movements()
    |> List.first()
    |> Lanternfish.gps()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path, wide: true)
    |> Lanternfish.movements()
    |> List.first()
    |> Lanternfish.gps()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
