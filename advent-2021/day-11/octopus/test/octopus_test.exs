defmodule OctopusTest do
  use ExUnit.Case
  doctest Octopus

  test "greets the world" do
    assert Octopus.hello() == :world
  end
end
