defmodule Packet do
  @moduledoc """
  Documentation for Packet.
  """

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
    # "[W]hat do you get if you add up the version numbers in all packets?"
    File.read!(input_file)
    |> Packet.Decoder.decode()
    |> Packet.Executor.version_sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    # "What do you get if you evaluate the expression represented by your
    # hexadecimal-encoded BITS transmission?"
    File.read!(input_file)
    |> Packet.Decoder.decode()
    |> List.first()  # FIXME decode() should return singleton
    |> Packet.Executor.calculate()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
