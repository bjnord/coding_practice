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

  test "removes pair from string (middle)" do
    assert remove_pair("aBcDeEfGh", 4) == "aBcDfGh"
  end

  test "removes pair from string (beginning)" do
    assert remove_pair("AaBbCcDdEe", 0) == "BbCcDdEe"
  end

  test "removes pair from string (pos 1)" do
    assert remove_pair("aBbCcDdEe", 1) == "aCcDdEe"
  end

  test "removes pair from string (pos 2)" do
    assert remove_pair("AaBbCcDdEe", 2) == "AaCcDdEe"
  end

  test "removes pair from string (end)" do
    assert remove_pair("AaBbCcDdEe", 8) == "AaBbCcDd"
  end
end
