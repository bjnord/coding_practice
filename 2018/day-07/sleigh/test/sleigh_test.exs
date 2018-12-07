defmodule SleighTest do
  use ExUnit.Case
  doctest Sleigh

  import Sleigh

  test "parses input lines" do
    assert parse_requirement("Step C must be finished before step A can begin.\n") == {"C", "A"}
    assert parse_requirement("Step A must be finished before step B can begin.\n") == {"A", "B"}
  end

  test "creates map of requirements" do
    reqs = [{"C", "A"}, {"C", "F"}, {"A", "B"}, {"A", "D"}, {"H", "G"}, {"B", "E"}, {"D", "E"}, {"F", "E"}, {"I", "G"}]
    assert requirements_map(reqs) == {
      %{"E" => ["F", "D", "B"], "B" => ["A"], "D" => ["A"], "A" => ["C"], "F" => ["C"], "G" => ["I", "H"]},
      Enum.into(["A", "B", "C", "D", "E", "F", "G", "H", "I"], MapSet.new())
    }
  end

  test "creates sorted list of steps with no dependencies" do
    reqmap = %{"E" => ["F", "D", "B"], "B" => ["A"], "D" => ["A"], "A" => ["C"], "F" => ["C"], "G" => ["I", "H"]}
    steps = ["I", "B", "G", "E", "F", "D", "C", "H", "A"]
    assert no_dependencies(steps, reqmap) == ["C", "H", "I"]
  end
end
