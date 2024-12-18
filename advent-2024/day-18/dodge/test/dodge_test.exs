defmodule DodgeTest do
  use ExUnit.Case
  doctest Dodge

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
        exp_block_pos: "6,1",
      ]
    end

    test "finds correct blocking_position", fixture do
      act_block_pos = fixture.input
                      |> Dodge.blocking_position(fixture.input_size)
      assert act_block_pos == fixture.exp_block_pos
    end
  end
end
