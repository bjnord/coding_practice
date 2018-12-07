defmodule SleighTest do
  use ExUnit.Case
  doctest Sleigh

  import Sleigh

  test "parses input lines" do
    assert parse_requirement("Step C must be finished before step A can begin.\n") == {"C", "A"}
    assert parse_requirement("Step A must be finished before step B can begin.\n") == {"A", "B"}
  end

  test "creates map of requirements" do
    reqs = [{"C", "A"}, {"C", "F"}, {"A", "B"}, {"A", "D"}, {"B", "E"}, {"D", "E"}, {"F", "E"}]
    assert requirements_map(reqs) == {
      %{"E" => ["F", "D", "B"], "B" => ["A"], "D" => ["A"], "A" => ["C"], "F" => ["C"]},
      Enum.into(["A", "B", "C", "D", "E", "F"], MapSet.new())
    }
  end
end
