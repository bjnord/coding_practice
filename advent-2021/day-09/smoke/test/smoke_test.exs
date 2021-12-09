defmodule SmokeTest do
  use ExUnit.Case
  doctest Smoke

  test "greets the world" do
    assert Smoke.hello() == :world
  end
end
