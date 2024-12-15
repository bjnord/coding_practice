defmodule Lanternfish.ParserTest do
  use ExUnit.Case
  doctest Lanternfish.Parser, import: true

  import Lanternfish.Parser
  alias History.Grid

  describe "puzzle example" do
    setup do
      [
        input: """
        ########
        #..O.O.#
        ##@.O..#
        #...O..#
        #.#.O..#
        #...O..#
        #......#
        ########

        <^^>>>vv
        <v>>v<<
        """,
        exp_grid: %Grid{
          size: %{y: 8, x: 8},
          squares: %{
            {0, 0} => ?#, {0, 1} => ?#, {0, 2} => ?#, {0, 3} => ?#,
            {0, 4} => ?#, {0, 5} => ?#, {0, 6} => ?#, {0, 7} => ?#,
            {1, 0} => ?#, {1, 3} => ?O, {1, 5} => ?O, {1, 7} => ?#,
            {2, 0} => ?#, {2, 1} => ?#, {2, 4} => ?O, {2, 7} => ?#,
            {3, 0} => ?#, {3, 4} => ?O, {3, 7} => ?#,
            {4, 0} => ?#, {4, 2} => ?#, {4, 4} => ?O, {4, 7} => ?#,
            {5, 0} => ?#, {5, 4} => ?O, {5, 7} => ?#,
            {6, 0} => ?#, {6, 7} => ?#,
            {7, 0} => ?#, {7, 1} => ?#, {7, 2} => ?#, {7, 3} => ?#,
            {7, 4} => ?#, {7, 5} => ?#, {7, 6} => ?#, {7, 7} => ?#,
          },
          meta: %{start: {2, 2}},
        },
        exp_directions: [
          :west, :north, :north, :east, :east, :east, :south, :south,
          :west, :south, :east, :east, :south, :west, :west,
        ],
      ]
    end

    test "produces correct grid", fixture do
      {act_grid, act_directions} =
        fixture.input
        |> parse_input_string()
      assert act_grid == fixture.exp_grid
      assert act_directions == fixture.exp_directions
    end
  end
end
