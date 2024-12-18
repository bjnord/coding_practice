defmodule Dodge.ParserTest do
  use ExUnit.Case
  doctest Dodge.Parser, import: true

  import Dodge.Parser
  alias History.Grid

  describe "puzzle example" do
    setup do
      [
        input: """
        5,4
        4,2
        4,5
        3,0
        2,1
        6,3
        2,4
        1,5
        0,6
        3,3
        2,6
        5,1
        1,2
        5,5
        2,5
        6,5
        1,4
        0,4
        6,4
        1,1
        6,1
        1,0
        0,5
        1,6
        2,0
        """,
        input_size: {7, 7},
        input_length: 12,
        exp_grid: %Grid{
          size: %{y: 7, x: 7},
          squares: %{
            {0, 3} => ?#,
            {1, 2} => ?#, {1, 5} => ?#,
            {2, 4} => ?#,
            {3, 3} => ?#, {3, 6} => ?#,
            {4, 2} => ?#, {4, 5} => ?#,
            {5, 1} => ?#, {5, 4} => ?#,
            {6, 0} => ?#, {6, 2} => ?#,
          },
          meta: %{start: {0, 0}, end: {6, 6}},
        },
      ]
    end

    test "produces correct grid", fixture do
      act_grid = fixture.input
                 |> parse_input_string(fixture.input_size, fixture.input_length)
      assert act_grid == fixture.exp_grid
    end
  end
end
