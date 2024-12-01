defmodule EarthTest do
  use ExUnit.Case
  doctest Earth

  import Earth

  describe "examples" do
    setup do
      [
        diggable_squares: [
          {
            {0, [0, 0]},
            false,
          },
          {
            {0, [1, 1, 1, 0]},
            false,
          },
          {
            {1, [0, 1, 1, 1]},
            false,
          },
          {
            {1, [1, 1, 1, 1]},
            true,
          },
          {
            {1, [1, 1, 1, 2]},
            true,
          },
          {
            {2, [1, 2, 2, 1]},
            false,
          },
          {
            {2, [2, 2, 2, 2]},
            true,
          },
        ]
      ]
    end

    test "detects correct diggable squares", fixture do
      act_diggable_squares =
        fixture.diggable_squares
        |> Enum.map(fn {{depth, neighbor_depths}, _is} ->
          is = diggable_square?(depth, neighbor_depths)
          {{depth, neighbor_depths}, is}
        end)
      assert act_diggable_squares == fixture.diggable_squares
    end
  end
end
