defmodule Immunity.CombatTest do
  use ExUnit.Case
  doctest Immunity.Combat

  import Immunity.Combat
  import Immunity.Group

  test "target selector precedence" do
    # NB "<" means "has earlier (higher) precedence than"
    group0 = new(0, 18, nil, nil, nil, 8, nil, 10)
    group1 = new(1, 100, nil, nil, nil, 16, nil, 9)
    assert target_selector_precedence(group1) < target_selector_precedence(group0)

    # initiative breaks ties in effective_power
    group2 = new(2, 800, nil, nil, nil, 2, nil, 8)
    assert target_selector_precedence(group1) < target_selector_precedence(group2)

    # but higher effective_power trumps higher initiative
    group3 = new(3, 801, nil, nil, nil, 2, nil, 7)
    assert target_selector_precedence(group1) > target_selector_precedence(group3)
  end

  test "damage multiplier" do
    group0 = new(0, nil, nil, [:fire], [], 0, :cold, 0)
    group1 = new(1, nil, nil, [], [:radiation], 0, :fire, 0)
    group2 = new(1, nil, nil, [], [], 0, :radiation, 0)

    assert damage_multiplier(group2, group1) == 2
    assert damage_multiplier(group2, group0) == 1
    assert damage_multiplier(group1, group0) == 0
    assert damage_multiplier(group1, group2) == 1
  end

  test "damage from attack" do
    group0 = new(0, 17, nil, [:fire], [], 7, :cold, 0)
    group1 = new(1, 19, nil, [], [:radiation], 5, :fire, 0)
    group2 = new(1, 23, nil, [], [], 3, :radiation, 0)

    assert damage_from_attack(group2, group1) == (23 * 3) * 2
    assert damage_from_attack(group2, group0) == 23 * 3
    assert damage_from_attack(group1, group0) == 0
    assert damage_from_attack(group1, group2) == 19 * 5
  end
end
