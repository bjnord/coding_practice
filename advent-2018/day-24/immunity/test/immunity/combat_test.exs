defmodule Immunity.CombatTest do
  use ExUnit.Case
  doctest Immunity.Combat

  import Immunity.Combat
  import Immunity.Group

  test "target precedence tuple" do
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
end
