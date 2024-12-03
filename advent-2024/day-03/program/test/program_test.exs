defmodule ProgramTest do
  use ExUnit.Case
  doctest Program

  describe "puzzle example" do
    setup do
      [
        instructions: [
          {:mul, [2, 4]},
          {:mul, [5, 5]},
          {:mul, [11, 8]},
          {:mul, [8, 5]},
        ],
        exp_result: 161,
      ]
    end

    test "processes instructions correctly", fixture do
      act_result = fixture.instructions
                   |> Program.process()
      assert act_result == fixture.exp_result
    end
  end
end
