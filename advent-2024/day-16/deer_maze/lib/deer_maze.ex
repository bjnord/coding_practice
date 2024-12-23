defmodule DeerMaze do
  @moduledoc """
  Documentation for `DeerMaze`.
  """

  alias DeerMaze.Graph
  import DeerMaze.Parser
  import History.CLI

  def score(grid) do
    graph = Graph.from_grid(grid)
    walk(graph, {{graph.meta.start, :east}, 0}, 0)
    |> List.flatten()
    |> Enum.min()
  end

  defp walk(_graph, {{_pos, dir}, cost}, score) when dir == :end, do: score + cost
  defp walk(graph, {{pos, dir}, cost}, score) do
    Map.get(graph.nodes, {pos, dir}, [])
    |> Enum.map(&(walk(graph, &1, score + cost)))
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
