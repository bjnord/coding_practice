defmodule Compact do
  @moduledoc """
  Documentation for `Compact`.
  """

  alias Compact.Disc
  import Compact.Parser
  import History.CLI

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
    |> Disc.create()
    |> Disc.compact()
    |> Disc.checksum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Disc.create()
    |> Disc.compact2()
    |> Disc.checksum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
