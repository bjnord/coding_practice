defmodule TeleportTest do
  use ExUnit.Case
  doctest Teleport

  import Teleport

  test "Manhattan distance 3-D" do
    assert manhattan({1, 3, 2}, {4, 1, 5}) == 3 + 2 + 3
  end
end
