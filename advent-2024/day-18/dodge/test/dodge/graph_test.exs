defmodule Dodge.GraphTest do
  use ExUnit.Case
  doctest Dodge.Graph, import: true

  alias Dodge.Graph
  alias History.Grid

  describe "puzzle example" do
    setup do
      [
        grid: %Grid{
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
        exp_min_steps: 22,
      ]
    end

    test "calculates lowest-cost path", fixture do
      act_min_steps = fixture.grid
                      |> Graph.new()
                      |> Graph.lowest_cost()
      assert act_min_steps == fixture.exp_min_steps
    end
  end
end
