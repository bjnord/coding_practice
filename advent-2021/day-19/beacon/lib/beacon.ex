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
    if Enum.member?(opts[:parts], 1), do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2), do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts) do
    # "Assemble the full map of beacons. How many beacons are there?"
    File.read!(input_file)
    |> Parser.parse()
    |> build_cloud(opts)
    |> elem(0)
    |> Scanner.beacons()
    |> Enum.count()
    |> IO.inspect(label: "Part 1 answer is")
  end

  # FIXME @doc
  def build_cloud(rel_beacon_sets, opts \\ []) do
    ###
    # we (arbitrarily) pick scanner 0 as the origin
    cloud = Scanner.new(rel_beacon_sets[0], {0, 0, 0}, 1, {0, 0, 0})
    rel_beacon_sets = Map.delete(rel_beacon_sets, 0)
    ###
    # find all the other scanners, by looking for correlations of at least
    # 12 beacons; fold each found scanner's beacons into the cloud
    1..map_size(rel_beacon_sets)
    |> Enum.reduce({cloud, [cloud], rel_beacon_sets}, fn (_, {cloud, scanners, rel_beacon_sets}) ->
      if opts[:verbose] do
        IO.inspect(map_size(rel_beacon_sets), label: "remaining scanners to find")
      end
      # find next scanner that correlates with one we've already found
      {n, t, offset} =
        find_next_correlation(cloud, rel_beacon_sets)
      # build scanner struct, and merge its beacons into the cloud
      scanner_n =
        Scanner.new(rel_beacon_sets[n], Scanner.origin(cloud), t, offset)
      cloud = Scanner.merge_beacons(cloud, scanner_n)
      # remove found scanner's relative beacons
      {cloud, [scanner_n | scanners], Map.delete(rel_beacon_sets, n)}
    end)
    |> Tuple.delete_at(2)
  end

  defp find_next_correlation(cloud, rel_beacon_sets) do
    # TODO `reduce_while()` seems the wrong choice here;
    #      `Enum.find_value()` maybe?
    Map.keys(rel_beacon_sets)
    |> Enum.reduce_while(0, fn (n, n_tried) ->
      {t, offset, count} =
        Scanner.beacons(cloud)
        |> Correlator.correlate(rel_beacon_sets[n])
      cond do
        count >= 12 ->
          {:halt, {n, t, offset}}
        n_tried + 1 >= map_size(rel_beacon_sets) ->
          {:halt, nil}
        true ->
          {:cont, n_tried + 1}
      end
    end)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts) do
    File.read!(input_file)
    |> Parser.parse()
    |> build_cloud(opts)
    |> elem(1)
    |> Scanner.max_manhattan()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
