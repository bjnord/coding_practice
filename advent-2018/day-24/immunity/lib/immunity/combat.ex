defmodule Immunity.Combat do
  @moduledoc """
  Documentation for Immunity.Combat.
  """

  import Immunity.Group

  @doc """
  Fight!
  """
  def fight(army1, army2) do
    groups =
      army1 ++ army2
      |> Enum.reduce(%{}, fn (group, acc) -> Map.put(acc, group.id, group) end)
    {targets, candidates_list} =
      groups
      |> target_selection_phase()
    {new_army1, new_army2, skirmishes} =
      groups
      |> attack_phase(targets)
    {new_army1, new_army2, targets, candidates_list, skirmishes}
  end

  @doc """
  Perform target selection phase.

  "At the end of the target selection phase, each group has selected
  zero or one groups to attack, and each group is being attacked by
  zero or one groups."
  """
  def target_selection_phase(groups) do
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

  @doc """
  Perform attack phase.
  """
  def attack_phase(groups, targets) do
    ###
    # determine order of groups getting to attack their targets
    attacker_list =
      Map.values(groups)
      |> Enum.sort_by(&(attacker_precedence(&1)))
      #|> IO.inspect(label: "attacker precedence")
    ###
    # have groups attack their targets
    {groups, _, r_skirmishes} =
      attacker_list
      |> Enum.reduce({groups, targets, []}, fn (att_group, {groups, targets, skirmishes}) ->
        accumulate_attack(att_group, groups, targets, skirmishes)
      end)
    #IO.inspect(groups, label: "groups after attack")
    #IO.inspect(r_skirmishes |> Enum.reverse(), label: "skirmishes")
    ###
    # collate back to armies, removing groups with no units left
    {new_army1, new_army2} =
      groups
      |> Enum.reduce({%{}, %{}}, fn ({_id, group}, {army1, army2}) ->
        # TODO cheating this assumes only two armies with IDs 1 and 2
        cond do
          group.units <= 0 -> {army1, army2}
          army_n(group) == 1 -> {[group | army1], army2}
          army_n(group) == 2 -> {army1, [group | army2]}
        end
      end)
    {new_army1, new_army2, r_skirmishes |> Enum.reverse()}
  end

  @doc """
  Sort function that determines order of attacks.

  "Groups attack in decreasing order of initiative, regardless of whether
  they are part of the infection or the immune system."
  """
  def attacker_precedence(group) do
    -group.initiative
  end

  @doc """
  Attack a target, if possible.

  "If a group contains no units, it cannot attack."
  """
  def accumulate_attack(att_group, groups, targets, skirmishes) do
    ###
    # get the latest data from groups map
    # (attacker may have less units now, if it was attacked this round)
    {def_group_id, _plan_damage} = targets[att_group.id]
    att_group = groups[att_group.id]
    def_group = groups[def_group_id]
    damage = damage_from_attack(att_group, def_group)
    ###
    # determine how many units were killed
    # if an attack happened, update groups and skirmishes
    if att_group.units > 0 do
      units_killed = units_lost_in_attack(def_group, damage)
      new_def_group = clone(def_group, :units, def_group.units - units_killed)
      skirmish = {att_group, new_def_group, units_killed}
      {Map.put(groups, def_group.id, new_def_group), targets, [skirmish | skirmishes]}
    else
      {groups, targets, skirmishes}
    end
  end

  @doc """
  Find units lost during attack.

  This will never return more than the defending group has.

  "The defending group only loses whole units from damage; damage is
  always dealt in such a way that it kills the most units possible, and any
  remaining damage to a unit that does not immediately kill it is ignored."
  """
  def units_lost_in_attack(def_group, damage) do
    unit_loss = div(damage, def_group.hp)
    min(def_group.units, unit_loss)
  end
end
