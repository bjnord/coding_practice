defmodule ComputerTest do
  use ExUnit.Case
  doctest Computer

  # TODO some edge-case tests
  #      - empty program should halt instantly, return same registers + empty output
  #      - combo op 7 should raise exception

  describe "puzzle example" do
    setup do
      [
        examples: [
          # If register C contains 9, the program 2,6 would set register B to 1.
          {
            {{0, 0, 9}, %{0 => 2, 1 => 6}},
            %{registers: {nil, 1, nil}},
          },
          # If register A contains 10, the program 5,0,5,1,5,4 would output 0,1,2.
          {
            {{10, 0, 0}, %{0 => 5, 1 => 0, 2 => 5, 3 => 1, 4 => 5, 5 => 4}},
            %{output: [0, 1, 2]},
          },
          # If register A contains 2024, the program 0,1,5,4,3,0 would output 4,2,5,6,7,7,7,7,3,1,0 and leave 0 in register A.
          # If register B contains 29, the program 1,7 would set register B to 26.
          # If register B contains 2024 and register C contains 43690, the program 4,0 would set register B to 44354.
        ],
        computer: {
          {729, 0, 0},
          %{0 => 0, 1 => 1, 2 => 5, 3 => 4, 4 => 3, 5 => 0},
        },
      ]
    end

    def assert_matches({act_registers, act_output}, expected) do
      exp_registers = Map.get(expected, :registers)
      if exp_registers do
        0..2
        |> Enum.each(fn i ->
          if elem(exp_registers, i) != nil do
            assert {?A + i, elem(act_registers, i)} == {?A + i, elem(exp_registers, i)}
          end
        end)
      end
      exp_output = Map.get(expected, :output)
      if exp_output do
        assert act_output == exp_output
      end
    end

    test "examples produce correct behavior", fixture do
      fixture.examples
      |> Enum.map(fn {computer, exp_result} ->
        assert_matches(Computer.run(computer), exp_result)
      end)
    end
  end
end
