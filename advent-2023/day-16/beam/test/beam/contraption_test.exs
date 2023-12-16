defmodule Beam.ContraptionTest do
  use ExUnit.Case
  doctest Beam.Contraption, import: true

  alias Beam.Contraption

  describe "puzzle example" do
    setup do
      [
        contraption: %Contraption{
          tiles: %{
            {0, 1} => ?|,
            {0, 5} => 92,  # ?\
            {1, 0} => ?|,
            {1, 2} => ?-,
            {1, 4} => 92,  # ?\
            {2, 5} => ?|,
            {2, 6} => ?-,
            {3, 8} => ?|,
            {5, 9} => 92,  # ?\
            {6, 4} => ?/,
            {6, 6} => 92,  # ?\
            {6, 7} => 92,  # ?\
            {7, 1} => ?-,
            {7, 3} => ?-,
            {7, 4} => ?/,
            {7, 7} => ?|,
            {8, 1} => ?|,
            {8, 6} => ?-,
            {8, 7} => ?|,
            {8, 9} => 92,  # ?\
            {9, 2} => ?/,
            {9, 3} => ?/,
            {9, 5} => ?|
          },
          size: {10, 10},
        },
        exp_n_energized: 46,
      ]
    end

    test "find energized tile count", fixture do
      act_n_energized = fixture.contraption
                        |> Contraption.n_energized()
      assert act_n_energized == fixture.exp_n_energized
    end
  end
end
