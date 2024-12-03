defmodule ProgramTest do
  use ExUnit.Case
  doctest Program

  describe "puzzle example" do
    setup do
      [
        mul_instructions: [
          {:mul, [2, 4]},
          {:mul, [5, 5]},
          {:mul, [11, 8]},
          {:mul, [8, 5]},
        ],
        exp_mul_result: 161,
        all_instructions: [
          {:mul, [2, 4]},
          {:"don't", []},
          {:mul, [5, 5]},
          {:mul, [11, 8]},
          {:do, []},
          {:mul, [8, 5]},
        ],
        exp_all_result: 48,
      ]
    end

    test "processes mul instructions correctly", fixture do
      act_mul_result = fixture.mul_instructions
                       |> Program.process_mul()
      assert act_mul_result == fixture.exp_mul_result
    end

    test "processes all instructions correctly", fixture do
      act_all_result = fixture.all_instructions
                       |> Program.process_all()
      assert act_all_result == fixture.exp_all_result
    end
  end
end
