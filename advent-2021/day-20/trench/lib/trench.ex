defmodule Trench do
  @moduledoc """
  Documentation for Trench.
  """

  alias Trench.Parser, as: Parser
  import Submarine.CLI

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
    # "Start with the original input image and apply the image enhancement
    # algorithm twice [...]. How many pixels are lit in the resulting image?"
    {_algor, _image} =
      File.read!(input_file)
      |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    {_algor, _image} =
      File.read!(input_file)
      |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
