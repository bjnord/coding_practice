defmodule PlutoTest do
  use ExUnit.Case
  doctest Pluto, import: true

  describe "puzzle examples" do
    setup do
      [
        stone_lines: [
          [0, 1, 10, 99, 999],
          [125, 17],
        ],
        exp_blink_line_groups: [
          [
            [1, 2024, 1, 0, 9, 9, 2021976],
          ],
          [
            [253000, 1, 7],
            [253, 0, 2024, 14168],
            [512072, 1, 20, 24, 28676032],
            [512, 72, 2024, 2, 0, 2, 4, 2867, 6032],
            [1036288, 7, 2, 20, 24, 4048, 1, 4048, 8096, 28, 67, 60, 32],
            [2097446912, 14168, 4048, 2, 0, 2, 4, 40, 48, 2024, 40, 48, 80, 96, 2, 8, 6, 7, 6, 0, 3, 2],
          ],
        ],
        exp_blink_stones: [
          {1, 7},
          {25, 55312},
        ]
      ]
    end

    test "produce expected blink lines", fixture do
      act_blink_lines =
        [fixture.stone_lines, fixture.exp_blink_line_groups]
        |> Enum.zip()
        |> Enum.map(fn {stone_line, exp_blink_lines} ->
          Pluto.blinks(stone_line, length(exp_blink_lines))
        end)
      assert act_blink_lines == fixture.exp_blink_line_groups
    end

    test "produce expected blink stones", fixture do
      act_blink_stones =
        [fixture.stone_lines, fixture.exp_blink_stones]
        |> Enum.zip()
        |> Enum.map(fn {stone_line, {n_blinks, _exp_n_stones}} ->
          {n_blinks, Pluto.n_stones(stone_line, n_blinks)}
        end)
      assert act_blink_stones == fixture.exp_blink_stones
    end
  end
end
