defmodule ShopTest do
  use ExUnit.Case
  doctest Shop

  test "greets the world" do
    assert Shop.hello() == :world
  end
end
