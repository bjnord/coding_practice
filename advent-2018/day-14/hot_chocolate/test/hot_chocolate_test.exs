defmodule HotChocolateTest do
  use ExUnit.Case
  doctest HotChocolate

  test "greets the world" do
    assert HotChocolate.hello() == :world
  end
end
