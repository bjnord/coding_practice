defmodule Wiring do
  @moduledoc """
  Documentation for `Wiring`.
  """

  import Wiring.Parser
  import Snow.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
    if Enum.member?(opts[:parts], 3), do: graph(input_file, :mermaid)
    if Enum.member?(opts[:parts], 4), do: graph(input_file, :graphviz)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    parse_input(input_file)
    nil  # TODO
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
  Generate graph.

  ## Parameters

  - `input_file`: file containing component wirings
  - `type`: graph type (`:mermaid` or `:graphviz`)
  """
  def graph(input_file, :mermaid) do
    filename = graph_filename(input_file, "graph.mm")
    parse_input(input_file)
    |> mermaid(filename)
    IO.puts("wrote #{filename}")
  end
  def graph(input_file, :graphviz) do
    filename = graph_filename(input_file, "graphviz.dot")
    parse_input(input_file)
    |> graphviz(filename)
    IO.puts("wrote #{filename}")
  end

  defp graph_filename(input_file, mm_file) do
    input_file
    |> String.split("/")
    |> then(fn [dir | _] -> "#{dir}/#{mm_file}" end)
  end

  @doc ~S"""
  Generate and write a [Mermaid](https://mermaid.js.org/) graph.

  ## Parameters

  - `links`: the list of component wirings (tuples)
  - `filename`: the filename to write
  """
  def mermaid(links, filename) do
    content =
      links
      |> Enum.uniq()
      |> Enum.map(fn {from, to} ->
        "#{from}-->#{to}"
      end)
      |> Enum.join("\n")
      |> then(fn c -> "graph TD\n#{c}\n" end)
    File.write!(filename, content)
  end

  @doc ~S"""
  Generate and write a [Graphviz](https://graphviz.org/) graph.

  ## Parameters

  - `links`: the list of component wirings (tuples)
  - `filename`: the filename to write
  """
  def graphviz(links, filename) do
    content =
      links
      |> Enum.uniq()
      |> Enum.map(fn {from, to} ->
        "  #{from} -- #{to}"
      end)
      |> Enum.join("\n")
      |> then(fn c -> "strict graph {\n#{c}\n}\n" end)
    File.write!(filename, content)
  end
end
