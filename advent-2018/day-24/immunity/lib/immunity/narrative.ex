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

  @doc """
  Narrative for fight.
  """
  def for_fight(army1, army2, _targets, candidates_list) do
    narrative_a =
      for_army(army1) ++ for_army(army2)
    narrative_ts =
      candidates_list
      |> Enum.reduce([], fn ({att_group, candidates}, lines) ->
        candidates
        |> Enum.reduce(lines, fn ({def_group, damage}, lines) ->
          sorter = {-army_n(att_group), group_n(att_group), group_n(def_group)}
          [{sorter, "#{army_name(att_group)} group #{group_n(att_group)} would deal defending group #{group_n(def_group)} #{damage} damage"} | lines]
        end)
      end)
      |> Enum.sort_by(fn ({sorter, _line}) -> sorter end)
      |> Enum.map(&(elem(&1, 1)))
    narrative_a ++ [""] ++ narrative_ts ++ [""]
  end
end
