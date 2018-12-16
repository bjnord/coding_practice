defmodule MachineTest do
  use ExUnit.Case
  doctest Machine

  test "greets the world" do
    assert Machine.hello() == :world
  end
end
