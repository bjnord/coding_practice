defmodule GalaxyTest do
  use ExUnit.Case
  doctest Galaxy

  describe "puzzle example" do
    setup do
      [
        image: [
          {0, 3},
          {1, 7},
          {2, 0},
          {4, 6},
          {5, 1},
          {6, 9},
          {8, 7},
          {9, 0},
          {9, 4},
        ],
        exp_max: {9, 9},
      ]
    end

    test "find max Y and X", fixture do
      act_image = fixture.image
                  |> Galaxy.max()
      assert act_image == fixture.exp_max
    end
  end
end
