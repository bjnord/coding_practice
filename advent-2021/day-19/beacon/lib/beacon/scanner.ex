defmodule Beacon.Scanner do
  @moduledoc """
  Scanner for `Beacon`.
  """

  alias Beacon.Scanner, as: Scanner
  alias Beacon.Transformer, as: Transformer
  alias Submarine.SubMath, as: SubMath

  # NB any variable with "beacon" in name is assumed **absolute**
  #    anything relative will have "rel_" in the name

  defstruct origin: {0, 0}, beacons: []

  @doc ~S"""
  Construct new scanner.

  The resulting scanner will have **absolute** origin and beacon positions,
  which other scanners can then correlate to.

  ## Parameters
  1. `rel_beacons`: list of relative `{x, y, z}` beacon positions
  1. `t` (transform), `offset`: to change them into absolute beacon positions
  """
  def new(rel_beacons, t, offset) do
    beacons =
      rel_beacons
      |> Enum.map(fn rb -> Transformer.transform(rb, t) end)
      |> Enum.map(fn rtb -> Transformer.position_sum(offset, rtb) end)
    %Scanner{
      origin: offset,
      beacons: beacons,
    }
  end

  @doc ~S"""
  Return (absolute) positions for the beacons this scanner can see.
  """
  def beacons(scanner) do
    scanner.beacons
  end

  @doc ~S"""
  Return this scanner's (absolute) origin position.
  """
  def origin(scanner) do
    scanner.origin
  end

  @doc ~S"""
  Merge beacons from `source_scanner` into this `scanner`.
  """
  def merge_beacons(scanner, source_scanner) do
    new_beacons =
      (scanner.beacons ++ source_scanner.beacons)
      |> Enum.uniq()
      |> Enum.sort()
    %Scanner{scanner | beacons: new_beacons}
  end

  @doc ~S"""
  Find maximum Manhattan distance between any two `scanners`.
  """
  def max_manhattan(scanners) do
    origins = Enum.map(scanners, &(Scanner.origin(&1)))
    origins
    |> Enum.flat_map(fn o1 ->
      Enum.map(origins, &(SubMath.manhattan(o1, &1)))
    end)
    |> Enum.max()
  end
end
