defmodule Packet.Executor do
  @moduledoc """
  Executor for `Packet`.
  """

  @doc ~S"""
  Return sum of (nested) versions of `packets`.
  """
  def version_sum(packets) do
    Enum.count(packets)  # TODO
  end
end
