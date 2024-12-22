defmodule Fence.ParserTest do
  use ExUnit.Case
  doctest Fence.Parser, import: true

  import Fence.Parser
  alias History.Grid

  describe "puzzle example" do
    setup do
      [
        input: """
        AAAA
        BBCD
        BBCC
        EEEC
        """,
        exp_grid: %Grid{
          size: %{y: 4, x: 4},
          squares: %{
            {0, 0} => ?A, {0, 1} => ?A, {0, 2} => ?A, {0, 3} => ?A,
            {1, 0} => ?B, {1, 1} => ?B, {1, 2} => ?C, {1, 3} => ?D,
            {2, 0} => ?B, {2, 1} => ?B, {2, 2} => ?C, {2, 3} => ?C,
            {3, 0} => ?E, {3, 1} => ?E, {3, 2} => ?E, {3, 3} => ?C,
          },
          meta: %{regions: [
            {?A, [{0, 0}, {0, 1}, {0, 2}, {0, 3}]},
            {?B, [{1, 0}, {1, 1}, {2, 0}, {2, 1}]},
            {?C, [{1, 2}, {2, 2}, {2, 3}, {3, 3}]},
            {?D, [{1, 3}]},
            {?E, [{3, 0}, {3, 1}, {3, 2}]},
          ]},
        },
      ]
    end

    test "produces correct grid", fixture do
      act_grid = fixture.input
                 |> parse_input_string()
      assert act_grid == fixture.exp_grid
    end
  end
end
