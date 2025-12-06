defmodule TrashTest do
  use ExUnit.Case
  doctest Trash

  import Trash

  describe "puzzle example" do
    setup do
      [
        equations: [
          {[123, 45, 6], :*},
          {[328, 64, 98], :+},
          {[51, 387, 215], :*},
          {[64, 23, 314], :+},
        ],
        exp_answers: [
          33210,
          490,
          4243455,
          401,
        ],
      ]
    end

    test "solver gets expected answers", fixture do
      act_answers = fixture.equations
                    |> Enum.map(&solve/1)
      assert act_answers == fixture.exp_answers
    end
  end
end
