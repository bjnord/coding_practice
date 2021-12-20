defmodule Beacon do
  @moduledoc """
  Documentation for Beacon.
  """

  alias Beacon.Correlator, as: Correlator
  alias Beacon.Parser, as: Parser
  alias Beacon.Scanner, as: Scanner
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
    # "Assemble the full map of beacons. How many beacons are there?"
    File.read!(input_file)
    |> Parser.parse()
    |> find()
    |> Enum.count()
    |> IO.inspect(label: "Part 1 answer is")
  end

  def find(rel_beacon_sets) do
    ###
    # we (arbitrarily) pick scanner 0 as the origin
    scanner_0 = Scanner.new(rel_beacon_sets[0], {0, 0, 0}, 1, {0, 0, 0})
    beacons_0 = Scanner.beacons(scanner_0)
    n_beacon_sets = map_size(rel_beacon_sets)
                    #|> IO.inspect(label: "n_beacon_sets")
    ###
    # find all the other scanners, by looking for correlations of
    # at least 12 beacons -- and accumulate beacons from all scanners
    1..n_beacon_sets-1
    |> Enum.reduce({%{0 => scanner_0}, beacons_0}, fn (_, {scanners, beacons}) ->
      #IO.inspect(map_size(scanners), label: "found scanner count")
      # find next scanner that correlates with one we've already found
      {n, n0, t, offset} =
        1..n_beacon_sets-1
        |> Enum.reject(&(Map.has_key?(scanners, &1)))
        |> Enum.find_value(&(find_correlation(scanners, rel_beacon_sets, &1)))
        #|> IO.inspect(label: "found correlation")  # USEFUL
      # build next scanner
      scanner_n =
        Scanner.new(rel_beacon_sets[n], Scanner.origin(scanners[n0]), t, offset)
        #|> IO.inspect(label: "newly built scanner #{n}")
      # get (absolute) beacon positions from previous scanner
      beacons_n = Scanner.beacons(scanner_n)
      # return next accumulator
      {Map.put(scanners, n, scanner_n), beacons ++ beacons_n}
    end)
    |> elem(1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp find_correlation(scanners, rel_beacon_sets, n) do
    # TODO cleaner as a comprehension?
    Enum.reduce_while(scanners, 0, fn ({n0, scanner}, n_tried) ->
      {t, offset, count} =
        Scanner.beacons(scanner)
        |> Correlator.correlate(rel_beacon_sets[n])
        #|> IO.inspect(label: "  attempted correlation of #{n} to #{n0} yields")  # USEFUL
      cond do
        count >= 12 ->
          {:halt, {n, n0, t, offset}}
        n_tried+1 >= map_size(scanners) ->
          {:halt, nil}
        true ->
          {:cont, n_tried+1}
      end
    end)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
