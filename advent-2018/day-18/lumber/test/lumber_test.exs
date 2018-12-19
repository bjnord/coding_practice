defmodule LumberTest do
  use ExUnit.Case
  doctest Lumber

  test "greets the world" do
    assert Lumber.hello() == :world
  end
end
