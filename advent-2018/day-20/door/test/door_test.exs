defmodule DoorTest do
  use ExUnit.Case
  doctest Door

  test "greets the world" do
    assert Door.hello() == :world
  end
end
