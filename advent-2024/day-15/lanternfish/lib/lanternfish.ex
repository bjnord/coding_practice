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

  def move(grid, pos, dir) do
    next_pos = delta_pos(pos, delta(dir))
    case Grid.get(grid, next_pos) do
      ?# ->
        {grid, pos}
      nil ->
        {grid, next_pos}
      ?O ->
        shift_boxes(grid, pos, next_pos, dir)
    end
  end

  defp shift_boxes(grid, pos, next_pos, dir) do
    {shift_pos, shift_ch} = beyond_box(grid, next_pos, dir, ?O)
    case shift_ch do
      ?# ->
        {grid, pos}
      nil ->
        shift_box(grid, next_pos, shift_pos)
    end
  end

  defp shift_box(grid, next_pos, shift_pos) do
    grid = Grid.delete(grid, next_pos)
           |> Grid.put(shift_pos, ?O)
    {grid, next_pos}
  end

  defp beyond_box(_grid, pos, _dir, ch) when ch != ?O, do: {pos, ch}
  defp beyond_box(grid, pos, dir, _ch) do
    next_pos = delta_pos(pos, delta(dir))
    beyond_box(grid, next_pos, dir, Grid.get(grid, next_pos))
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
      ch == ?# -> ?#
      ch == ?O -> ?O
      true     -> ?.
    end
  end

  def gps({grid, _pos}) do
    Grid.keys(grid)
    |> Enum.reduce(0, fn {y, x} = pos, acc ->
      case Grid.get(grid, pos) do
        ?O -> y * 100 + x + acc
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
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
