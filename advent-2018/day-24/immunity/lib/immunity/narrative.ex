defmodule Immunity.Narrative do
  @moduledoc """
  Documentation for Immunity.Narrative.
  """

  import Immunity.Group

  @doc """
  Narrative for army.
  """
  def for_army(army) do
    army_name =
      army
      |> Enum.take(1)
      |> List.first
      |> army_name()
    army
    |> Enum.reduce(["#{army_name}:"], fn (group, lines) ->
      lines ++ [for_group(group)]
    end)
  end

  @doc """
  Narrative for group.
  """
  def for_group(group) do
    "Group #{group_n(group)} contains #{group.units} units"
  end
end
