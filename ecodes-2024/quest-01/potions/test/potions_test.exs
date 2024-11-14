defmodule PotionsTest do
  use ExUnit.Case
  doctest Potions

  test "puzzle example" do
    assert Potions.calc("ABBAC") == 5
  end
end
