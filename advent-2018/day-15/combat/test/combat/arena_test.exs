defmodule Combat.ArenaTest do
  use ExUnit.Case
  doctest Combat.Arena

  import Combat.Arena

  #  Targets:      In range:     Reachable:    Nearest:      Chosen:
  #  #######       #######       #######       #######       #######
  #  #E..G.#       #E.?G?#       #E.@G.#       #E.!G.#       #E.+G.#
  #  #...#.#  -->  #.?.#?#  -->  #.@.#.#  -->  #.!.#.#  -->  #...#.#
  #  #.G.#G#       #?G?#G#       #@G@#G#       #!G.#G#       #.G.#G#
  #  #######       #######       #######       #######       #######

  test "next_position() puzzle example" do
    arena =
      {%{}, MapSet.new()}
      |> parse_line("#######\n", 0)
      |> parse_line("#E..G.#\n", 1)
      |> parse_line("#...#.#\n", 2)
      |> parse_line("#.G.#G#\n", 3)
      |> parse_line("#######\n", 4)
    mover =
      {{1, 1}, :elf, 3, 200}
    opponents = find_combatants(arena, :goblin)
    assert next_position(arena, mover, opponents) == {
      {1, 3},
      [{{1, 4}, :goblin, 3, 200}]
    }
  end

  #  In range:     Nearest:      Chosen:       Distance:     Step:
  #  #######       #######       #######       #######       #######
  #  #.E...#       #.E...#       #.E...#       #4E212#       #..E..#
  #  #...?.#  -->  #...!.#  -->  #...+.#  -->  #32101#  -->  #.....#
  #  #..?G?#       #..!G.#       #...G.#       #432G2#       #...G.#
  #  #######       #######       #######       #######       #######

  test "next_step_toward() puzzle example" do
    arena =
      {%{}, MapSet.new()}
      |> parse_line("#######\n", 0)
      |> parse_line("#.E...#\n", 1)
      |> parse_line("#.....#\n", 2)
      |> parse_line("#...G.#\n", 3)
      |> parse_line("#######\n", 4)
    mover = {{1, 2}, :elf, 3, 200}
    # (make sure test is constructed correctly:)
    assert MapSet.member?(elem(arena, 1), mover)
    opponents = find_combatants(arena, :goblin)
    candidate = next_position(arena, mover, opponents)
    assert elem(candidate, 0) == {2, 4}
    assert next_step_toward(arena, mover, candidate) == {1, 3}
  end

  test "fight(:pacifist) puzzle example" do
    round_0 =
      {%{}, MapSet.new()}
      |> parse_line("#########\n", 0)
      |> parse_line("#G..G..G#\n", 1)
      |> parse_line("#.......#\n", 2)
      |> parse_line("#.......#\n", 3)
      |> parse_line("#G..E..G#\n", 4)
      |> parse_line("#.......#\n", 5)
      |> parse_line("#.......#\n", 6)
      |> parse_line("#G..G..G#\n", 7)
      |> parse_line("#########\n", 8)
    round_1 =
      {%{}, MapSet.new()}
      |> parse_line("#########\n", 0)
      |> parse_line("#.G...G.#\n", 1)
      |> parse_line("#...G...#\n", 2)
      |> parse_line("#...E..G#\n", 3)
      |> parse_line("#.G.....#\n", 4)
      |> parse_line("#.......#\n", 5)
      |> parse_line("#G..G..G#\n", 6)
      |> parse_line("#.......#\n", 7)
      |> parse_line("#########\n", 8)
    assert fight(round_0, :pacifist) == {round_1, false}

     round_2 =
       {%{}, MapSet.new()}
       |> parse_line("#########\n", 0)
       |> parse_line("#..G.G..#\n", 1)
       |> parse_line("#...G...#\n", 2)
       |> parse_line("#.G.E.G.#\n", 3)
       |> parse_line("#.......#\n", 4)
       |> parse_line("#G..G..G#\n", 5)
       |> parse_line("#.......#\n", 6)
       |> parse_line("#.......#\n", 7)
       |> parse_line("#########\n", 8)
     assert fight(round_1, :pacifist) == {round_2, false}

     round_3 =
       {%{}, MapSet.new()}
       |> parse_line("#########\n", 0)
       |> parse_line("#.......#\n", 1)
       |> parse_line("#..GGG..#\n", 2)
       |> parse_line("#..GEG..#\n", 3)
       |> parse_line("#G..G...#\n", 4)
       |> parse_line("#......G#\n", 5)
       |> parse_line("#.......#\n", 6)
       |> parse_line("#.......#\n", 7)
       |> parse_line("#########\n", 8)
     assert fight(round_2, :pacifist) == {round_3, false}
     assert fight(round_3, :pacifist) == {round_3, false}
  end

  test "fight(:puzzle) puzzle example [beginning]" do
    {grid_0, roster_0} =
      {%{}, MapSet.new()}
      |> parse_line("#######\n", 0)
      |> parse_line("#.G...#\n", 1)
      |> parse_line("#...EG#\n", 2)
      |> parse_line("#.#.#G#\n", 3)
      |> parse_line("#..G#E#\n", 4)
      |> parse_line("#.....#\n", 5)
      |> parse_line("#######\n", 6)

    {grid_1, roster_1} =
      {%{}, MapSet.new()}
      |> parse_line("#######\n", 0)
      |> parse_line("#..G..#\n", 1)
      |> parse_line("#...EG#\n", 2)
      |> parse_line("#.#G#G#\n", 3)
      |> parse_line("#...#E#\n", 4)
      |> parse_line("#.....#\n", 5)
      |> parse_line("#######\n", 6)
    {{grid_0_result, roster_0_result}, done_after_0} = fight({grid_0, roster_0}, :puzzle)
    assert grid_0_result == grid_1
    assert roster_0_result == MapSet.new([
      {{1, 3}, :goblin, 3, 200},
      {{2, 4}, :elf, 3, 197},
      {{2, 5}, :goblin, 3, 197},
      {{3, 3}, :goblin, 3, 200},
      {{3, 5}, :goblin, 3, 197},
      {{4, 5}, :elf, 3, 197},
    ])
    assert done_after_0 == false
  end

  test "fight(:puzzle) puzzle example [ending]" do
    {grid_47, roster_47} =
      {%{}, MapSet.new()}
      |> parse_line("#######\n", 0)
      |> parse_line("#G....#\n", 1)
      |> parse_line("#.G...#\n", 2)
      |> parse_line("#.#.#G#\n", 3)
      |> parse_line("#...#.#\n", 4)
      |> parse_line("#....G#\n", 5)
      |> parse_line("#######\n", 6)
    # what it would have had, after 47 rounds:
    roster_47 = MapSet.new([
      {{1, 1}, :goblin, 3, 200},
      {{2, 2}, :goblin, 3, 131},
      {{3, 5}, :goblin, 3, 59},
      {{5, 5}, :goblin, 3, 200},
    ])
    {{grid_47_result, roster_47_result}, done_after_47} = fight({grid_47, roster_47}, :puzzle)
    assert grid_47_result == grid_47
    assert roster_47_result == roster_47
    assert done_after_47 == true
  end
end
