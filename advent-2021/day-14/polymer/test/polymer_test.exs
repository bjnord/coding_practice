defmodule PolymerTest do
  use ExUnit.Case
  doctest Polymer

  test "greets the world" do
    assert Polymer.hello() == :world
  end
end
