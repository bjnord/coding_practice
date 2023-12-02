defmodule CubeTest do
  use ExUnit.Case
  doctest Cube

  test "greets the world" do
    assert Cube.hello() == :world
  end
end
