defmodule Immunity.GroupTest do
  use ExUnit.Case
  doctest Immunity.Group

  import Immunity.Group

  test "effective power" do
    # 18 units each with 729 hit points (weak to fire; immune to cold, slashing)
    #  with an attack that does 8 radiation damage at initiative 10
    group = new(0, 18, 729, {:weakness, [:fire]}, {:immunity, [:cold, :slashing]}, 8, :radiation, 10)
    assert effective_power(group) == 144
  end
end
