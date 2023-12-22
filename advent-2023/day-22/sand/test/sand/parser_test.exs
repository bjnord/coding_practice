defmodule Sand.ParserTest do
  use ExUnit.Case
  doctest Sand.Parser, import: true

  import Sand.Parser
  alias Sand.Brick

  describe "puzzle example" do
    setup do
      [
        input: """
        1,0,1~1,2,1
        0,0,2~2,0,2
        0,2,3~2,2,3
        0,0,4~0,2,4
        2,0,5~2,2,5
        0,1,6~2,1,6
        1,1,8~1,1,9
        """,
        exp_bricks: [
          %Brick{n: 1, from: %{x: 1, y: 0, z: 1}, to: %{x: 1, y: 2, z: 1}},
          %Brick{n: 2, from: %{x: 0, y: 0, z: 2}, to: %{x: 2, y: 0, z: 2}},
          %Brick{n: 3, from: %{x: 0, y: 2, z: 3}, to: %{x: 2, y: 2, z: 3}},
          %Brick{n: 4, from: %{x: 0, y: 0, z: 4}, to: %{x: 0, y: 2, z: 4}},
          %Brick{n: 5, from: %{x: 2, y: 0, z: 5}, to: %{x: 2, y: 2, z: 5}},
          %Brick{n: 6, from: %{x: 0, y: 1, z: 6}, to: %{x: 2, y: 1, z: 6}},
          %Brick{n: 7, from: %{x: 1, y: 1, z: 8}, to: %{x: 1, y: 1, z: 9}},
        ],
        double_input: """
        1,0,1~1,2,1
        0,0,2~2,0,2
        0,2,3~2,2,3
        0,0,4~0,2,4
        2,0,5~2,2,5
        0,1,6~2,1,6
        1,1,8~1,1,9
        1,0,11~1,2,11
        0,0,12~2,0,12
        0,2,13~2,2,13
        0,0,14~0,2,14
        2,0,15~2,2,15
        0,1,16~2,1,16
        1,1,18~1,1,19
        """,
        exp_double_bricks: [
          %Brick{n:  1, from: %{x: 1, y: 0, z:  1}, to: %{x: 1, y: 2, z:  1}},
          %Brick{n:  2, from: %{x: 0, y: 0, z:  2}, to: %{x: 2, y: 0, z:  2}},
          %Brick{n:  3, from: %{x: 0, y: 2, z:  3}, to: %{x: 2, y: 2, z:  3}},
          %Brick{n:  4, from: %{x: 0, y: 0, z:  4}, to: %{x: 0, y: 2, z:  4}},
          %Brick{n:  5, from: %{x: 2, y: 0, z:  5}, to: %{x: 2, y: 2, z:  5}},
          %Brick{n:  6, from: %{x: 0, y: 1, z:  6}, to: %{x: 2, y: 1, z:  6}},
          %Brick{n:  7, from: %{x: 1, y: 1, z:  8}, to: %{x: 1, y: 1, z:  9}},
          %Brick{n:  8, from: %{x: 1, y: 0, z: 11}, to: %{x: 1, y: 2, z: 11}},
          %Brick{n:  9, from: %{x: 0, y: 0, z: 12}, to: %{x: 2, y: 0, z: 12}},
          %Brick{n: 10, from: %{x: 0, y: 2, z: 13}, to: %{x: 2, y: 2, z: 13}},
          %Brick{n: 11, from: %{x: 0, y: 0, z: 14}, to: %{x: 0, y: 2, z: 14}},
          %Brick{n: 12, from: %{x: 2, y: 0, z: 15}, to: %{x: 2, y: 2, z: 15}},
          %Brick{n: 13, from: %{x: 0, y: 1, z: 16}, to: %{x: 2, y: 1, z: 16}},
          %Brick{n: 14, from: %{x: 1, y: 1, z: 18}, to: %{x: 1, y: 1, z: 19}},
        ],
      ]
    end

    test "parser gets expected bricks", fixture do
      act_bricks = fixture.input
                   |> parse_input_string()
      assert act_bricks == fixture.exp_bricks
    end

    test "parser gets expected bricks (double example)", fixture do
      act_double_bricks = fixture.double_input
                          |> parse_input_string()
      assert act_double_bricks == fixture.exp_double_bricks
    end
  end
end
