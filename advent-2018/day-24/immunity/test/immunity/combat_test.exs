defmodule Immunity.CombatTest do
  use ExUnit.Case
  doctest Immunity.Combat

  import Immunity.Combat
  import Immunity.Group

  test "target selector precedence" do
    # NB "<" means "has earlier (higher) precedence than"
    group0 = new({0, 0}, 18, nil, nil, nil, 8, nil, 10)
    group1 = new({1, 1}, 100, nil, nil, nil, 16, nil, 9)
    assert target_selector_precedence(group1) < target_selector_precedence(group0)

    # initiative breaks ties in effective_power
    group2 = new({0, 2}, 800, nil, nil, nil, 2, nil, 8)
    assert target_selector_precedence(group1) < target_selector_precedence(group2)

    # but higher effective_power trumps higher initiative
    group3 = new({0, 3}, 801, nil, nil, nil, 2, nil, 7)
    assert target_selector_precedence(group1) > target_selector_precedence(group3)
  end

  test "damage multiplier" do
    group0 = new({0, 0}, nil, nil, [:fire], [], 0, :cold, 0)
    group1 = new({1, 1}, nil, nil, [], [:radiation], 0, :fire, 0)
    group2 = new({0, 2}, nil, nil, [], [], 0, :radiation, 0)

    assert damage_multiplier(group2, group1) == 2
    assert damage_multiplier(group2, group0) == 1
    assert damage_multiplier(group1, group0) == 0
    assert damage_multiplier(group1, group2) == 1
  end

  test "damage from attack" do
    group0 = new({0, 0}, 17, nil, [:fire], [], 7, :cold, 0)
    group1 = new({1, 1}, 19, nil, [], [:radiation], 5, :fire, 0)
    group2 = new({0, 2}, 23, nil, [], [], 3, :radiation, 0)

    assert damage_from_attack(group2, group1) == (23 * 3) * 2
    assert damage_from_attack(group2, group0) == 23 * 3
    assert damage_from_attack(group1, group0) == 0
    assert damage_from_attack(group1, group2) == 19 * 5
  end

  # "For example, if a defending group contains 10 units with 10 hit
  # points each and receives 75 damage, it loses exactly 7 units and
  # is left with 3 units at full health."
  test "units lost in attack" do
    group0 = new({0, 0}, 10, 10, nil, nil, nil, nil, nil)
    assert units_lost_in_attack(group0, 75) == 7
  end

  test "units lost in massive attack" do
    group0 = new({0, 0}, 10, 10, nil, nil, nil, nil, nil)
    assert units_lost_in_attack(group0, 75_000) == 10
  end
end
