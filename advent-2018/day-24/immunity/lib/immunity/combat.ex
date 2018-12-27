defmodule Immunity.Combat do
  @moduledoc """
  Documentation for Immunity.Combat.
  """

  import Immunity.Group

  @doc """
  Fight!
  """
  def fight(army1, army2) do
    all_groups = army1 ++ army2
    target_selection(all_groups)
  end

  @doc """
  Perform target selection.

  "At the end of the target selection phase, each group has selected
  zero or one groups to attack, and each group is being attacked by
  zero or one groups."
  """
  def target_selection(groups) do
    selecting_groups =
      groups
      |> Enum.sort_by(&(target_selector_precedence(&1)))
      #|> IO.inspect(label: "target_selector_precedence")
  end

  @doc """
  Sort function that determines order of target selection.

  "In decreasing order of effective power, groups choose their targets;
  in a tie, the group with the higher initiative chooses first."
  """
  def target_selector_precedence(group) do
    {-effective_power(group), -group.initiative}
  end
end
