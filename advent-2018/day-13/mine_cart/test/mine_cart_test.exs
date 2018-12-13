defmodule MineCartTest do
  use ExUnit.Case
  doctest MineCart

  test "greets the world" do
    assert MineCart.hello() == :world
  end
end
