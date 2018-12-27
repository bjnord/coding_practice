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
  def for_fight(army1, army2, candidates_list, skirmishes) do
    narr_arm = army_narrative(army1, army2)
    narr_ts = target_selection_narrative(candidates_list)
    narr_att = attack_narrative(skirmishes)
    narr_arm ++ [""] ++ narr_ts ++ [""] ++ narr_att
  end

  defp army_narrative(army1, army2) do
    for_army(army1) ++ for_army(army2)
  end

  defp target_selection_narrative(candidates_list) do
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
  end

  defp attack_narrative(skirmishes) do
    skirmishes
    |> Enum.reduce([], fn ({att_group, def_group, units_killed}, lines) ->
      ["#{army_name(att_group)} group #{group_n(att_group)} attacks defending group #{group_n(def_group)}, killing #{units_killed} units" | lines]
    end)
    |> Enum.reverse()
  end
end
