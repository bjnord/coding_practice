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
    {cloud, scanners} =
      File.read!(input_file)
      |> Parser.parse()
      |> build_cloud(opts)
    if Enum.member?(opts[:parts], 1), do: part1(cloud)
    if Enum.member?(opts[:parts], 2), do: part2(scanners)
  end

  @doc """
  Produce and display part 1 solution.
  """
  def part1(cloud) do
    # "Assemble the full map of beacons. How many beacons are there?"
    cloud
    |> Scanner.beacons()
    |> Enum.count()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Build a single `Scanner` by progressively correlating and folding in
  all the given `rel_beacon_sets`.

  Returns `{cloud_scanner, scanners}`.
  """
  def build_cloud(rel_beacon_sets, opts \\ []) do
    ###
    # we (arbitrarily) pick scanner 0 as the origin
    cloud = Scanner.new(rel_beacon_sets[0], 1, {0, 0, 0})
    rel_beacon_sets = Map.delete(rel_beacon_sets, 0)
    ###
    # find all the other scanners, by looking for correlations of at least
    # 12 beacons; fold each found scanner's beacons into the cloud
    acc = {cloud, [cloud], rel_beacon_sets}
    1..map_size(rel_beacon_sets)
    |> Enum.reduce(acc, fn (_, {cloud, scanners, rel_beacon_sets}) ->
      if opts[:verbose] do
        IO.inspect(map_size(rel_beacon_sets), label: "scanners left to find")
      end
      # find next scanner that correlates with one we've already found
      {n, t, offset} = find_next_correlation(cloud, rel_beacon_sets)
      # build scanner struct, and merge its beacons into the cloud
      scanner_n = Scanner.new(rel_beacon_sets[n], t, offset)
      cloud = Scanner.merge_beacons(cloud, scanner_n)
      # remove found scanner's relative beacons
      {cloud, [scanner_n | scanners], Map.delete(rel_beacon_sets, n)}
    end)
    |> Tuple.delete_at(2)
  end

  defp find_next_correlation(cloud, rel_beacon_sets) do
    rel_beacon_sets
    |> Enum.find_value(fn {n, rel_beacon_set} ->
      {t, offset, count} =
        Scanner.beacons(cloud)
        |> Correlator.correlate(rel_beacon_set)
      if count >= 12, do: {n, t, offset}, else: nil
    end)
  end

  @doc """
  Produce and display part 2 solution.
  """
  def part2(scanners) do
    # "What is the largest Manhattan distance between any two scanners?"
    scanners
    |> Scanner.max_manhattan()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
