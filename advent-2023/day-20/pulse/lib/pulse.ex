defmodule Pulse do
  @moduledoc """
  Documentation for `Pulse`.
  """

  import Pulse.Parser
  alias Pulse.Network
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
    parse_input(input_file)
    |> Network.n_pushes(1_000)
    |> then(fn {lo, hi} -> lo * hi end)
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    network = parse_input(input_file)
    break_on = break_on(network)
    Network.n_pushes_break(network, break_on)
    |> IO.inspect(label: "Part 2 answer is")
  end

  defp break_on(network) do
    to_rx =
      network.modules
      |> Enum.find(fn {_k, {_type, dests}} ->
        dests
        |> Enum.find(fn dest -> dest == :rx end)
      end)
    if to_rx, do: :rx, else: :output
  end
end
