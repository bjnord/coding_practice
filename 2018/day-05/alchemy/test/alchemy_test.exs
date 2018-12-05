defmodule AlchemyTest do
  use ExUnit.Case
  doctest Alchemy

  import Alchemy

  test "scans string for reactant (found #1)" do
    assert reactant_at("Aa", 0) == true
  end

  test "scans string for reactant (found #2)" do
    assert reactant_at("zZ", 0) == true
  end

  test "scans string for reactant (different letters)" do
    assert reactant_at("bN", 0) == false
  end

  test "scans string for reactant (same polarity #1)" do
    assert reactant_at("aa", 0) == false
  end

  test "scans string for reactant (same polarity #2)" do
    assert reactant_at("ZZ", 0) == false
  end

  test "scans string for reactant (found in middle)" do
    assert reactant_at("aBcDeEfGh", 4) == true
  end

  test "scans string for reactant (straddling end of string)" do
    assert reactant_at("Aa", 1) == false
  end

  test "scans string for reactant (off end of string)" do
    assert reactant_at("Aa", 2) == false
  end
end
