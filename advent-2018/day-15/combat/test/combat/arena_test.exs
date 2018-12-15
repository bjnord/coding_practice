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
end
