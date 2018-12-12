defmodule PlantsTest do
  use ExUnit.Case
  doctest Plants

  test "greets the world" do
    assert Plants.hello() == :world
  end
end
