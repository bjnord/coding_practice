defmodule TeleportTest do
  use ExUnit.Case
  doctest Teleport

  test "greets the world" do
    assert Teleport.hello() == :world
  end
end
