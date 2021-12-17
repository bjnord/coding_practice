defmodule Packet.Executor do
  @moduledoc """
  Executor for `Packet`.
  """

  @doc ~S"""
  Return sum of the versions found in (nested) `packets`.
  """
  def version_sum({version, {type, arg}}) do
    case type do
      :literal -> version
      _ -> version + subpkts_version_sum(arg)
    end
  end
  defp subpkts_version_sum(subpkts) do
    Enum.map(subpkts, fn subpkt -> version_sum(subpkt) end)
    |> Enum.sum()
  end

  @doc ~S"""
  Return value calculated from packet (including its nested packets).
  """
  def calculate({_version, {type, arg}}) do
    case type do
      :op_sum -> calculate_sum(arg)
      :op_prod -> calculate_prod(arg)
      :op_min -> calculate_min(arg)
      :op_max -> calculate_max(arg)
      :literal -> arg
      :op_gt -> calculate_gt(arg)
      :op_lt -> calculate_lt(arg)
      :op_eq -> calculate_eq(arg)
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
