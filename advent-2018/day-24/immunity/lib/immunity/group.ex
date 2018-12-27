defmodule Immunity.Group do
  @moduledoc """
  Documentation for Immunity.Group.
  """

  @enforce_keys [:id, :units, :hp, :weakness, :immunity, :attack, :attack_type, :initiative]
  defstruct id: nil, units: 0, hp: 0, weakness: [], immunity: [], attack: 0, attack_type: nil, initiative: 0

  @type t() :: %__MODULE__{
    id: tuple(),
    units: integer(),
    hp: integer(),
    weakness: list(),
    immunity: list(),
    attack: integer(),
    attack_type: atom(),
    initiative: integer(),
  }

  @doc """
  Construct a new group.
  """
  def new(id, units, hp, immunity, weakness, attack, attack_type, initiative) do
    %Immunity.Group{id: id, units: units, hp: hp, weakness: weakness, immunity: immunity, attack: attack, attack_type: attack_type, initiative: initiative}
  end

  @doc """
  Clone a group, replacing one of its values.
  """
  def clone(group, field, new_value) when field == :units do
    %Immunity.Group{id: group.id, units: new_value, hp: group.hp, weakness: group.weakness, immunity: group.immunity, attack: group.attack, attack_type: group.attack_type, initiative: group.initiative}
  end

  @doc """
  Get army number of group.
  """
  def army_n(group) do
    elem(group.id, 0)
  end

  @doc """
  Get army name of group.
  """
  def army_name(group) do
    # TODO cheating; this should come from the parsed input.
    case army_n(group) do
      1 -> "Immune System"
      2 -> "Infection"
    end
  end

  @doc """
  Get group number of group.
  """
  def group_n(group) do
    elem(group.id, 1)
  end

  @doc """
  Create tag for group.

  This is used as a human-friendly ID for debug output etc.
  """
  def tag(group) do
    "#{army_n(group)}-#{String.slice(Atom.to_string(group.attack_type), 0..4)}-#{group_n(group)}"
  end

  @doc """
  Find effective power of group.
  """
  def effective_power(group) do
    group.units * group.attack
  end

  @doc """
  Find total number of units of army.
  """
  def total_units(army) do
    Enum.map(army, fn (group) -> group.units end)
    |> Enum.sum()
  end
end
