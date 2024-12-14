defmodule Robot.ParserTest do
  use ExUnit.Case
  doctest Robot.Parser, import: true

  import Robot.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        p=0,4 v=3,-3
        p=6,3 v=-1,-3
        p=10,3 v=-1,2
        p=2,0 v=2,-1
        p=0,0 v=1,3
        p=3,0 v=-2,-2
        p=7,6 v=-1,-3
        p=3,0 v=-1,-2
        p=9,3 v=2,3
        p=7,3 v=-1,2
        p=2,4 v=2,-3
        p=9,5 v=-3,-3
        """,
        exp_robots: [
          {{4, 0}, {-3, 3}},
          {{3, 6}, {-3, -1}},
          {{3, 10}, {2, -1}},
          {{0, 2}, {-1, 2}},
          {{0, 0}, {3, 1}},
          {{0, 3}, {-2, -2}},
          {{6, 7}, {-3, -1}},
          {{0, 3}, {-2, -1}},
          {{3, 9}, {3, 2}},
          {{3, 7}, {2, -1}},
          {{4, 2}, {-3, 2}},
          {{5, 9}, {-3, -3}},
        ],
      ]
    end

    test "parser gets expected robots", fixture do
      act_robots = fixture.input
                   |> parse_input_string()
                   |> Enum.to_list()
      assert act_robots == fixture.exp_robots
    end
  end
end
