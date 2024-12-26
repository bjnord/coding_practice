defmodule PlutoTest do
  use ExUnit.Case
  doctest Pluto, import: true

  describe "puzzle examples" do
    setup do
      [
        example_stone_maps: [
          # If you have an arrangement of five stones engraved with
          # the numbers 0 1 10 99 999
          %{0 => 1, 1 => 1, 10 => 1, 99 => 1, 999 => 1},
          # Initial arrangement:
          # 125 17
          %{125 => 1, 17 => 1},
        ],
        exp_blink_stone_maps: [
          # So, after blinking once, your five stones would become
          # an arrangement of seven stones engraved with the numbers
          # 1 2024 1 0 9 9 2021976.
          [
            %{0 => 1, 1 => 2, 9 => 2, 2024 => 1, 2021976 => 1},
          ],
          # After 1 blink:
          # 253000 1 7
          #
          # After 2 blinks:
          # 253 0 2024 14168
          #
          # After 3 blinks:
          # 512072 1 20 24 28676032
          #
          # After 4 blinks:
          # 512 72 2024 2 0 2 4 2867 6032
          #
          # After 5 blinks:
          # 1036288 7 2 20 24 4048 1 4048 8096 28 67 60 32
          #
          # After 6 blinks:
          # 2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2
          [
            %{1 => 1, 7 => 1, 253000 => 1},
            %{0 => 1, 253 => 1, 2024 => 1, 14168 => 1},
            %{1 => 1, 20 => 1, 24 => 1, 512072 => 1, 28676032 => 1},
            %{
              0 => 1, 2 => 2, 4 => 1, 72 => 1, 512 => 1,
              2024 => 1, 2867 => 1, 6032 => 1,
            },
            %{
              1 => 1, 2 => 1, 7 => 1,
              20 => 1, 24 => 1, 28 => 1, 32 => 1, 60 => 1, 67 => 1,
              4048 => 2, 8096 => 1, 1036288 => 1,
            },
            %{
              0 => 2, 2 => 4, 3 => 1, 4 => 1, 6 => 2, 7 => 1, 8 => 1,
              40 => 2, 48 => 2, 80 => 1, 96 => 1,
              2024 => 1, 4048 => 1, 14168 => 1, 2097446912 => 1,
            },
          ],
        ],
        exp_blink_stones: [
          {1, 7},
          {25, 55312},
        ],
      ]
    end

    test "produce expected blink stone maps", fixture do
      example_blink_counts =
        fixture.exp_blink_stone_maps
        |> Enum.map(&Enum.count/1)
      act_blink_stone_maps =
        [fixture.example_stone_maps, example_blink_counts]
        |> Enum.zip()
        |> Enum.map(fn {stone_map_0, blink_count} ->
          1..blink_count
          |> Enum.reduce({stone_map_0, []}, fn _, {stone_map, acc} ->
            stone_map = Pluto.blink(stone_map)
            {stone_map, [stone_map | acc]}
          end)
          |> elem(1)
          |> Enum.reverse()
        end)
      assert act_blink_stone_maps == fixture.exp_blink_stone_maps
    end

    test "produce expected blink stones", fixture do
      act_blink_stones = [  # TODO
        {1, 0},
        {25, 0},
      ]
      assert act_blink_stones == fixture.exp_blink_stones
    end
  end
end
