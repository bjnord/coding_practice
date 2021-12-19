defmodule Beacon.Scanner do
  @moduledoc """
  Scanner for `Beacon`.
  """

  alias Beacon.Transformer, as: Transformer

  defstruct origin: {0, 0}, abs_beacons: []

  @doc ~S"""
  Construct new scanner from a list of relative beacon positions, and
  the origin, transform, and offset needed to change them into absolute
  beacon positions.
  """
  def new(rel_beacons, origin, t, offset) do
    abs_beacons =
      rel_beacons
      |> Enum.map(fn rb -> Transformer.transform(rb, t) end)
      |> Enum.map(fn rtb -> Transformer.position_sum(offset, rtb) end)
      # FIXME need to add origin to rtb also?
    %Beacon.Scanner{
      origin: Transformer.position_sum(origin, offset),
      abs_beacons: abs_beacons,
    }
  end

  @doc ~S"""
  Return absolute positions for the beacons this scanner can see.
  """
  def abs_beacons(scanner) do
    scanner.abs_beacons
  end

  @doc ~S"""
  Return this scanner's origin position.
  """
  def origin(scanner) do
    scanner.origin
  end
end
