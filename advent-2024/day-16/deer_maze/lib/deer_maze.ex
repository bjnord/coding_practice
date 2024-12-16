defmodule DeerMaze do
  @moduledoc """
  Documentation for `DeerMaze`.
  """

  import DeerMaze.Parser
  import History.CLI
  alias History.Grid

  def score(grid) do
    walk(grid, {grid.meta.start, :east, 0}, %{}, 0)
    |> List.flatten()
    |> Enum.min()
  end

  defp walk(grid, {pos, _dir, cost}, _seen, score) when pos == grid.meta.end, do: score + cost
  defp walk(grid, {pos, dir, cost}, seen, score) do
    choices = branches(grid, pos, dir, seen)
    case length(choices) do
      0 ->
        nil
      1 ->
        walk(grid, hd(choices), Map.put(seen, pos, true), score + cost)
      _ ->
        choices
        |> Enum.map(fn choice ->
          walk(grid, choice, Map.put(seen, pos, true), score + cost)
        end)
    end
  end

  defp branches(grid, pos, dir, seen) do
    Grid.cardinals_of(grid, pos)
    |> Enum.reject(fn npos ->
      (Grid.get(grid, npos) == ?#) || Map.get(seen, npos)
    end)
    |> Enum.map(&(branch_to_choice(pos, dir, &1)))
  end

  defp branch_to_choice(pos, dir, npos) do
    ndir = dir_of(pos, npos)
    if dir == ndir do
      {npos, dir, 1}
    else
      {npos, ndir, 1001}
    end
  end

  defp dir_of({y, x}, {ny, nx}) do
    dir_of({ny - y, nx - x})
  end
  defp dir_of({-1, 0}), do: :north
  defp dir_of({0, 1}), do: :east
  defp dir_of({1, 0}), do: :south
  defp dir_of({0, -1}), do: :west

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
    |> DeerMaze.score()
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
