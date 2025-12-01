defmodule SafeTest do
  use ExUnit.Case
  doctest Safe

  test "greets the world" do
    assert Safe.hello() == :world
  end
end
