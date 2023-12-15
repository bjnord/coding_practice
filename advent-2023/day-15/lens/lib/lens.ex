defmodule Lens do
  @moduledoc """
  Documentation for `Lens`.
  """

  alias Lens.Boxes
  import Lens.Parser
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
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    # TODO use `Lens.Parser`
    File.read!(input_file)
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&Lens.hash/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file, part: 2)
    |> Boxes.install()
    |> Boxes.power()
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc ~S"""
  Compute HASH value of string.

  ## Parameters

  - `str`: the string (string or charlist)

  Returns the HASH value (integer from 0-255).
  """
  def hash(str) when is_binary(str) do
    str
    |> String.trim_trailing()
    |> String.to_charlist()
    |> hash()
  end
  def hash(str) when is_list(str) do
    str
    |> Enum.reduce(0, fn ch, acc ->
      rem((acc + ch) * 17, 256)
    end)
  end
end
