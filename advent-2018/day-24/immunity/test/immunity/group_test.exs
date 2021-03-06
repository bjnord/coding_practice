defmodule Immunity.GroupTest do
  use ExUnit.Case
  doctest Immunity.Group

  import Immunity.Group

  test "army_n" do
    assert army_n(new({1, 2}, nil, nil, nil, nil, nil, nil, nil)) == 1
    assert army_n(new({7, 9}, nil, nil, nil, nil, nil, nil, nil)) == 7
  end

  test "group_n" do
    assert group_n(new({1, 2}, nil, nil, nil, nil, nil, nil, nil)) == 2
    assert group_n(new({7, 9}, nil, nil, nil, nil, nil, nil, nil)) == 9
  end

  test "effective power" do
    # 18 units each with 729 hit points (weak to fire; immune to cold, slashing)
    #  with an attack that does 8 radiation damage at initiative 10
    group = new({1, 1}, 18, 729, {:weakness, [:fire]}, {:immunity, [:cold, :slashing]}, 8, :radiation, 10)
    assert effective_power(group) == 144
  end

  test "total units" do
    group0 = new({0, 0}, 18, nil, nil, nil, nil, nil, nil)
    group1 = new({0, 1}, 2019, nil, nil, nil, nil, nil, nil)
    group2 = new({0, 2}, 1, nil, nil, nil, nil, nil, nil)
    assert total_units([group0, group1, group2]) == 2038
  end
end
