defmodule ChronalTest do
  use ExUnit.Case
  doctest Chronal

  test "greets the world" do
    assert Chronal.hello() == :world
  end
end
