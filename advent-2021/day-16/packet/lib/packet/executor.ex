defmodule Packet.Executor do
  @moduledoc """
  Executor for `Packet`.
  """

  @doc ~S"""
  Return sum of the versions found in (nested) `packets`.
  """
  def version_sum(packets), do: version_sum(packets, 0)
  defp version_sum(packets, sum) when packets == [], do: sum
  defp version_sum([{version, {type, _subtype, op}} | packets], sum) do
    case type do
      :literal -> version_sum(packets, sum + version)
      :operator -> version_sum(packets, sum + version + version_sum(op, 0))
    end
  end

  @doc ~S"""
  Return value calculated from packet (including its nested packets).
  """
  def calculate({_version, {type, subtype, op}}) do
    case {type, subtype} do
      {:literal, _} -> op
      {:operator, 0} -> calculate_sum(op)
      {:operator, 1} -> calculate_prod(op)
      {:operator, 2} -> calculate_min(op)
      {:operator, 3} -> calculate_max(op)
      {:operator, 5} -> calculate_gt(op)
      {:operator, 6} -> calculate_lt(op)
      {:operator, 7} -> calculate_eq(op)
    end
  end

  # "Packets with type ID 0 are sum packets - their value is the sum of
  # the values of their sub-packets. If they only have a single sub-packet,
  # their value is the value of the sub-packet."
  defp calculate_sum(subpkts) do
    Enum.map(subpkts, &calculate/1)
    |> Enum.sum()
  end

  # "Packets with type ID 1 are product packets - their value is the result
  # of multiplying together the values of their sub-packets. If they only
  # have a single sub-packet, their value is the value of the sub-packet."
  defp calculate_prod(subpkts) do
    Enum.map(subpkts, &calculate/1)
    |> Enum.reduce(&*/2)
  end

  # "Packets with type ID 2 are minimum packets - their value is the
  # minimum of the values of their sub-packets."
  defp calculate_min(subpkts) do
    Enum.map(subpkts, &calculate/1)
    |> Enum.min()
  end

  # "Packets with type ID 3 are maximum packets - their value is the
  # maximum of the values of their sub-packets."
  defp calculate_max(subpkts) do
    Enum.map(subpkts, &calculate/1)
    |> Enum.max()
  end

  # "Packets with type ID 5 are greater than packets - their value is 1
  # if the value of the first sub-packet is greater than the value of the
  # second sub-packet; otherwise, their value is 0. These packets always
  # have exactly two sub-packets."
  defp calculate_gt([subpkt1, subpkt2]) do
    if calculate(subpkt1) > calculate(subpkt2), do: 1, else: 0
  end

  # "Packets with type ID 6 are less than packets - their value is 1 if
  # the value of the first sub-packet is less than the value of the second
  # sub-packet; otherwise, their value is 0. These packets always have
  # exactly two sub-packets."
  defp calculate_lt([subpkt1, subpkt2]) do
    if calculate(subpkt1) < calculate(subpkt2), do: 1, else: 0
  end

  # "Packets with type ID 7 are equal to packets - their value is 1 if
  # the value of the first sub-packet is equal to the value of the second
  # sub-packet; otherwise, their value is 0. These packets always have
  # exactly two sub-packets."
  defp calculate_eq([subpkt1, subpkt2]) do
    if calculate(subpkt1) == calculate(subpkt2), do: 1, else: 0
  end
end
