defmodule HotChocolate.ScoreboardTest do
  use ExUnit.Case
  doctest HotChocolate.Scoreboard

  test "new() with invalid score" do
    assert_raise HotChocolate.InvalidScore, "score -1 outside range 0..9", fn ->
      HotChocolate.Scoreboard.new([-1])
    end
  end
end
