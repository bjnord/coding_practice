defmodule AlchemyTest do
  use ExUnit.Case
  doctest Alchemy

  import Alchemy

  test "scans string for reactant (found #1)" do
    assert reactant_at(["A", "a"], 0) == true
  end

  test "scans string for reactant (found #2)" do
    assert reactant_at(["z", "Z"], 0) == true
  end

  test "scans string for reactant (different letters)" do
    assert reactant_at(["b", "N"], 0) == false
  end

  test "scans string for reactant (same polarity #1)" do
    assert reactant_at(["a", "a"], 0) == false
  end

  test "scans string for reactant (same polarity #2)" do
    assert reactant_at(["Z", "Z"], 0) == false
  end

  test "scans string for reactant (found in middle)" do
    assert reactant_at(["a", "B", "c", "D", "e", "E", "f", "G", "h"], 4) == true
  end

  test "scans string for reactant (straddling end of string)" do
    assert reactant_at(["A", "a"], 1) == false
  end

  test "scans string for reactant (off end of string)" do
    assert reactant_at(["A", "a"], 2) == false
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
