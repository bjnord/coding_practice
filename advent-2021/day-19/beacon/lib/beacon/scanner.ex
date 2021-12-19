defmodule Beacon.Scanner do
  @moduledoc """
  Scanner for `Beacon`.
  """

  alias Beacon.Transformer, as: Transformer

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
  1. `origin`: origin of scanner the beacons were correlated to
  """
  def new(rel_beacons, origin, t, offset) do
    beacons =
      rel_beacons
      |> Enum.map(fn rb -> Transformer.transform(rb, t) end)
      |> Enum.map(fn rtb -> Transformer.position_sum(offset, rtb) end)
    %Beacon.Scanner{
      origin: Transformer.position_sum(origin, offset),
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
end
