defmodule ImmunityTest do
  use ExUnit.Case
  doctest Immunity

  test "greets the world" do
    assert Immunity.hello() == :world
  end
end
