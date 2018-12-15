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
end
