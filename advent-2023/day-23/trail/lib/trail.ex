defmodule Trail do
  @moduledoc """
  Documentation for `Trail`.
  """

  import Snow.CLI
  alias Trail.Maze
  import Trail.Parser

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
    if Enum.member?(opts[:parts], 3), do: mermaid(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    parse_input(input_file)
    |> Maze.path_lengths()
    |> Enum.max()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Generate Mermaid graphs.
  """
  def mermaid(input_file) do
    maze = parse_input(input_file)
    # part 1 (DAG)
    filename = mermaid_filename(input_file, "part1-graph.mm")
    Maze.mermaid(maze, :dag, filename)
    IO.puts("wrote #{filename}")
    # part 2 (cyclic)
    filename2 = mermaid_filename(input_file, "part2-graph.mm")
    Maze.mermaid(maze, :cyclic, filename2)
    IO.puts("wrote #{filename2}")
  end

  defp mermaid_filename(input_file, mm_file) do
    input_file
    |> String.split("/")
    |> then(fn [dir | _] -> "#{dir}/#{mm_file}" end)
  end
end
