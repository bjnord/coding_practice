defmodule Immunity.NarrativeTest do
  use ExUnit.Case
  doctest Immunity.Narrative

  import Immunity.Narrative

  test "fight" do
    expected_narrative = [
      "Immune System:",
      "Group 1 contains 17 units",
      "Group 2 contains 989 units",
      "Infection:",
      "Group 1 contains 801 units",
      "Group 2 contains 4485 units",
      "",
      "Infection group 1 would deal defending group 1 185832 damage",
      "Infection group 1 would deal defending group 2 185832 damage",
      "Infection group 2 would deal defending group 2 107640 damage",
      "Immune System group 1 would deal defending group 1 76619 damage",
      "Immune System group 1 would deal defending group 2 153238 damage",
      "Immune System group 2 would deal defending group 1 24725 damage",
      "",
      "Infection group 2 attacks defending group 2, killing 84 units",
      "Immune System group 2 attacks defending group 1, killing 4 units",
      "Immune System group 1 attacks defending group 2, killing 51 units",
      "Infection group 1 attacks defending group 1, killing 17 units",
    ]
    [army1, army2] =
      "input/example1.txt"
      |> File.read!
      |> Immunity.InputParser.parse_input_content()
    {_new_army1, _new_army2, targets, candidates_list, skirmishes} =
      Immunity.Combat.fight(army1, army2)
    actual_narrative =
      for_fight(army1, army2, targets, candidates_list, skirmishes)
    assert actual_narrative == expected_narrative
  end
end
