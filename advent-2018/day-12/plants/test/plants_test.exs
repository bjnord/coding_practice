defmodule PlantsTest do
  use ExUnit.Case
  doctest Plants
  doctest InputParser

  import Plants

  test "greets the world" do
    assert hello() == :world
  end
end
