defmodule CombatTest do
  use ExUnit.Case
  doctest Combat

  test "greets the world" do
    assert Combat.hello() == :world
  end
end
