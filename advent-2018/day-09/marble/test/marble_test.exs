defmodule MarbleTest do
  use ExUnit.Case
  doctest Marble

  test "greets the world" do
    assert Marble.hello() == :world
  end
end
