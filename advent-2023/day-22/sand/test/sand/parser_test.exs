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
      ]
    end

    test "parser gets expected bricks", fixture do
      act_bricks = fixture.input
                   |> parse_input_string()
      assert act_bricks == fixture.exp_bricks
    end
  end
end
