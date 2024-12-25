defmodule LockTest do
  use ExUnit.Case
  doctest Lock

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
        exp_fits: 3,
      ]
    end

    test "find number of lock-and-key fits", fixture do
      act_fits = fixture.input
                 |> parse_input_string()
                 |> Lock.fits()
      assert act_fits == fixture.exp_fits
    end
  end
end
