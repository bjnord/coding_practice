defmodule SleighTest do
  use ExUnit.Case
  doctest Sleigh

  import Sleigh

  test "parses input lines" do
    assert parse_requirement("Step C must be finished before step A can begin.\n") == {"C", "A"}
    assert parse_requirement("Step A must be finished before step B can begin.\n") == {"A", "B"}
  end
end
