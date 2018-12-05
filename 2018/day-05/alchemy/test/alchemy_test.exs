defmodule AlchemyTest do
  use ExUnit.Case
  doctest Alchemy

  test "greets the world" do
    assert Alchemy.hello() == :world
  end
end
