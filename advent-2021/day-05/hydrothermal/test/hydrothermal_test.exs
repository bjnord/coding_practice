defmodule HydrothermalTest do
  use ExUnit.Case
  doctest Hydrothermal

  describe "puzzle example" do
    setup do
      [
        vents: [
          [{0, 9}, {5, 9}],
          [{8, 0}, {0, 8}],
          [{9, 4}, {3, 4}],
          [{2, 2}, {2, 1}],
          [{7, 0}, {7, 4}],
          [{6, 4}, {2, 0}],
          [{0, 9}, {2, 9}],
          [{3, 4}, {1, 4}],
          [{0, 0}, {8, 8}],
          [{5, 5}, {8, 2}],
        ],
        exp_hv_intersections: 5,
        exp_intersections: 12,
      ]
    end

    test "correct count of horiz/vert vent intersections", fixture do
      hv_vents = fixture.vents
                 |> Enum.filter(&Hydrothermal.horiz_or_vert?/1)
      assert Hydrothermal.vent_intersections(hv_vents) == fixture.exp_hv_intersections
    end

    test "correct count of all vent intersections", fixture do
      assert Hydrothermal.vent_intersections(fixture.vents) == fixture.exp_intersections
    end
  end
end
