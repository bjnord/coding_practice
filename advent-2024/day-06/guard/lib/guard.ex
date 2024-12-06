defmodule Guard do
  @moduledoc """
  Documentation for `Guard`.
  """

  alias Xmas.Grid
  import Guard.Parser
  import Snow.CLI

  @debug false

  def path_length(grid) do
    walk(grid, start_pos(grid), {-1, 0}, 0)
  end

  defp start_pos(grid) do
    Grid.keys(grid)
    |> Enum.find(fn pos -> Grid.get(grid, pos) == ?^ end)
  end

  defp walk(grid, {y, x}, {dy, dx}, acc) do
    ny = y + dy
    nx = x + dx
    cond do
      !Grid.in_bounds?(grid, {ny, nx}) ->
        # walked off edge; done
        if @debug, do: mark(grid, {y, x}) |> dump()
        accumulate(grid, {y, x}, acc)
      Grid.get(grid, {ny, nx}) == ?# ->
        # turn but don't move
        if @debug, do: mark(grid, {y, x}) |> dump()
        walk(grid, {y, x}, turn({dy, dx}), acc)
      true ->
        # move one square forward
        walk(mark(grid, {y, x}), {ny, nx}, {dy, dx}, accumulate(grid, {y, x}, acc))
    end
  end

  defp mark(grid, pos) do
    Grid.get_and_update(grid, pos, &({&1, ?X}))
  end

  # when walking forward, only count squares we haven't walked before
  defp accumulate(grid, pos, acc) do
    case Grid.get(grid, pos) do
      ?X -> acc
      _  -> acc + 1
    end
  end

  defp dump(grid) do
    0..(grid.size.y - 1)
    |> Enum.map(&(dump_line(grid, &1)))
    IO.puts("")
  end

  defp dump_line(grid, y) do
    0..(grid.size.x - 1)
    |> Enum.map(&(Grid.get(grid, {y, &1})))
    |> Enum.map(&dump_char/1)
    |> List.to_string()  # FIXME necessary?
    |> IO.puts()
  end

  defp dump_char(ch) do
    case ch do
      ?#  -> ?#
      ?^  -> ?X
      ?X  -> ?X
      _   -> ?.
    end
  end

  # 90-degree right turn
  defp turn({dy, dx}) do
    case {dy, dx} do
      {-1, 0} -> {0, 1}
      {0, 1}  -> {1, 0}
      {1, 0}  -> {0, -1}
      {0, -1} -> {-1, 0}
    end
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
    |> Guard.path_length()
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
