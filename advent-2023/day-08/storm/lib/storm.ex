defmodule Storm do
  @moduledoc """
  Documentation for `Storm`.
  """

  import Storm.Parser
  alias Storm.Map
  import Snow.CLI
  alias Snow.SnowMath

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    parse_input(input_file)
    |> Map.steps()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    map = parse_input(input_file)
    Map.a_nodes(map)
    |> Enum.map(fn node -> Map.cycle_length(map, node) end)
    |> SnowMath.lcm()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
