defmodule Immunity.Group do
  @moduledoc """
  Documentation for Immunity.Group.
  """

  @enforce_keys [:id, :units, :hp, :weakness, :immunity, :attack, :attack_type, :initiative]
  defstruct id: nil, units: 0, hp: 0, weakness: [], immunity: [], attack: 0, attack_type: nil, initiative: 0

  @type t() :: %__MODULE__{
    id: String.t(),
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
  @spec new(String.t(), integer(), integer(), tuple(), tuple(), integer(), atom(), integer()) :: Immunity.Group.t()

  def new(id, units, hp, immunity, weakness, attack, attack_type, initiative) do
    %Immunity.Group{id: id, units: units, hp: hp, weakness: weakness, immunity: immunity, attack: attack, attack_type: attack_type, initiative: initiative}
  end

  @doc """
  Get army number from group ID.
  """
  def army_n(group) do
    String.slice(group.id, 0..0)
    |> String.to_integer()
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
  Find effective power of group.
  """
  @spec effective_power(Immunity.Group.t()) :: integer()

  def effective_power(group) do
    group.units * group.attack
  end

  @doc """
  Dump army state.
  """
  def dump_army(army) do
    army_name =
      army
      |> Enum.take(1)
      |> List.first
      |> army_name()
    army
    |> Enum.reduce(["#{army_name}:"], fn (group, lines) ->
      lines ++ [dump(group)]
    end)
  end

  @doc """
  Dump group state.
  """
  def dump(group) do
    group_id =
      String.split(group.id, "-")
      |> Enum.at(2)
    "Group #{group_id} contains #{group.units} units"
  end
end
