defmodule TreeTest do
  use ExUnit.Case
  doctest Tree

  import Tree

  test "parses string to integers" do
    assert parse_integers("1 5 2 4 3\n") == [1, 5, 2, 4, 3]
  end
end
