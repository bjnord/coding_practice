defmodule WhaleTest do
  use ExUnit.Case
  doctest Whale

  test "greets the world" do
    assert Whale.hello() == :world
  end
end
