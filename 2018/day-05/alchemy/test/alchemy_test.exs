defmodule AlchemyTest do
  use ExUnit.Case
  doctest Alchemy

  import Alchemy

  test "test letter pair for reactance (reactant)" do
    assert reactant?("A", "a") == true
    assert reactant?("z", "Z") == true
  end

  test "test letter pair for reactance (nonreactant)" do
    assert reactant?("a", "a") == false
    assert reactant?("Z", "Z") == false
  end

  test "test letter pair for reactance (different letters)" do
    assert reactant?("b", "N") == false
  end
end
