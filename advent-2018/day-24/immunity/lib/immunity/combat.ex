defmodule Immunity.Combat do
  @moduledoc """
  Documentation for Immunity.Combat.
  """

  import Immunity.Group

  @doc """
  Fight!
  """
  def fight(army1, army2) do
    army1 ++ army2
    |> Enum.reduce(%{}, fn (group, acc) -> Map.put(acc, group.id, group) end)
    |> target_selection()
  end

  @doc """
  Perform target selection.

  "At the end of the target selection phase, each group has selected
  zero or one groups to attack, and each group is being attacked by
  zero or one groups."
  """
  def target_selection(groups) do
    ###
    # determine order of groups getting to select their targets
    selector_list =
      Map.values(groups)
      |> Enum.sort_by(&(target_selector_precedence(&1)))
      #|> IO.inspect(label: "target selector precedence")
    ###
    # have groups select their targets
    {_, targets, r_candidates_list} =
      selector_list
      |> Enum.reduce({groups, %{}, []}, fn (att_group, {groups, targets, candidates_list}) ->
        accumulate_target(att_group, groups, targets, candidates_list)
      end)
    #IO.inspect(targets, label: "targets")
    {targets, r_candidates_list |> Enum.reverse()}
  end

  @doc """
  Sort function that determines order of target selection.

  "In decreasing order of effective power, groups choose their targets;
  in a tie, the group with the higher initiative chooses first."
  """
  def target_selector_precedence(group) do
    {-effective_power(group), -group.initiative}
  end

  @doc """
  Select a target, if possible.

  "If [an attacking group" cannot deal any defending groups damage,
  it does not choose a target. Defending groups can only be chosen as
  a target by one attacking group."
  """
  def accumulate_target(att_group, groups, targets, candidates_list) do
    candidates =
      Map.values(groups)
      |> Enum.reject(fn (group) -> army_n(group) == army_n(att_group) end)
      |> Enum.map(fn (group) -> {group, damage_from_attack(att_group, group)} end)
      |> Enum.reject(fn ({_group, damage}) -> damage <= 0 end)
      |> Enum.sort_by(fn ({group, damage}) -> target_choice(group, damage) end)
      #|> IO.inspect(label: "target priority for #{tag(att_group)}")
    case candidates do
      [] ->
        {groups, targets, candidates_list}
      [{def_group, damage} | _rest] ->
        {
          Map.delete(groups, def_group.id),
          Map.put(targets, att_group.id, {def_group.id, damage}),
          [{att_group, candidates} | candidates_list]
        }
    end
  end

  @doc """
  Sort function for target choice.

  "The attacking group chooses to target the group in the enemy army to
  which it would deal the most damage (after accounting for weaknesses
  and immunities, but not accounting for whether the defending group
  has enough units to actually receive all of that damage)"

  "If an attacking group is considering two defending groups to which
  it would deal equal damage, it chooses to target the defending group
  with the largest effective power; if there is still a tie, it chooses
  the defending group with the highest initiative."
  """
  def target_choice(def_group, damage) do
    {-damage, -effective_power(def_group), -def_group.initiative}
  end

  @doc """
  Find damage from attack.

  "By default, an attacking group would deal damage equal to its
  effective power to the defending group." [but see "However" below]
  """
  def damage_from_attack(att_group, def_group) do
    effective_power(att_group) * damage_multiplier(att_group, def_group)
  end

  @doc """
  Find damage multiplier.

  "However, if the defending group is immune to the attacking group's
  attack type, the defending group instead takes no damage; if the
  defending group is weak to the attacking group's attack type, the
  defending group instead takes double damage."
  """
  def damage_multiplier(att_group, def_group) do
    cond do
      att_group.attack_type in def_group.immunity ->
        0
      att_group.attack_type in def_group.weakness ->
        2
      true ->
        1
    end
  end
end
