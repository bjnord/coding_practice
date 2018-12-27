defmodule Immunity.Group do
  @moduledoc """
  Documentation for Immunity.Group.
  """

  @enforce_keys [:army_n, :units, :hp, :weakness, :immunity, :attack, :attack_type, :initiative]
  defstruct army_n: 0, units: 0, hp: 0, weakness: [], immunity: [], attack: 0, attack_type: nil, initiative: 0

  @type t() :: %__MODULE__{
    army_n: integer(),
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
  @spec new(integer(), integer(), integer(), tuple(), tuple(), integer(), atom(), integer()) :: Immunity.Group.t()

  def new(army_n, units, hp, immunity, weakness, attack, attack_type, initiative) do
    %Immunity.Group{army_n: army_n, units: units, hp: hp, weakness: weakness, immunity: immunity, attack: attack, attack_type: attack_type, initiative: initiative}
  end

  @doc """
  Find effective power of group.
  """
  @spec effective_power(Immunity.Group.t()) :: integer()

  def effective_power(group) do
    group.units * group.attack
  end
end
