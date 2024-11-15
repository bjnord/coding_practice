defmodule PotionsTest do
  use ExUnit.Case
  doctest Potions

  test "part 1 example" do
    assert Potions.calc_p1("ABBAC") == 5
  end

  test "part 2 example" do
    assert Potions.calc_p2("AxBCDDCAxD") == 28
  end

  # (the puzzle description doesn't cover this case, but it appears in
  # the part 2 input file)
  test "part 2 with no creatures" do
    assert Potions.calc_p2("xx") == 0
  end
end
