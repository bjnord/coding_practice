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
end
