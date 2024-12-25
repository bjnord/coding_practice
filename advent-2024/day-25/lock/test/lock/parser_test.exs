defmodule Lock.ParserTest do
  use ExUnit.Case
  doctest Lock.Parser, import: true

  import Lock.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        #####
        .####
        .####
        .####
        .#.#.
        .#...
        .....

        #####
        ##.##
        .#.##
        ...##
        ...#.
        ...#.
        .....

        .....
        #....
        #....
        #...#
        #.#.#
        #.###
        #####

        .....
        .....
        #.#..
        ###..
        ###.#
        ###.#
        #####

        .....
        .....
        .....
        #....
        #.#..
        #.#.#
        #####
        """,
        exp_locks_keys: [
          {:lock, [
            {0, 0b1000000},
            {5, 0b1111110},
            {3, 0b1111000},
            {4, 0b1111100},
            {3, 0b1111000},
          ]},
          {:lock, [
            {1, 0b1100000},
            {2, 0b1110000},
            {0, 0b1000000},
            {5, 0b1111110},
            {3, 0b1111000},
          ]}, 
          {:key, [
            {5, 0b0111111},
            {0, 0b0000001},
            {2, 0b0000111},
            {1, 0b0000011},
            {3, 0b0001111},
          ]}, 
          {:key, [
            {4, 0b0011111},
            {3, 0b0001111},
            {4, 0b0011111},
            {0, 0b0000001},
            {2, 0b0000111},
          ]}, 
          {:key, [
            {3, 0b0001111},
            {0, 0b0000001},
            {2, 0b0000111},
            {0, 0b0000001},
            {1, 0b0000011},
          ]}, 
        ],
      ]
    end

    test "parser gets expected locks and keys", fixture do
      act_locks_keys = fixture.input
                       |> parse_input_string()
                       |> Enum.to_list()
      assert act_locks_keys == fixture.exp_locks_keys
    end
  end
end
