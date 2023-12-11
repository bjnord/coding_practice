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
        exp_empties: {
          [3, 7],
          [2, 5, 8],
        },
      ]
    end

    test "find max Y and X", fixture do
      act_image = fixture.image
                  |> Galaxy.max()
      assert act_image == fixture.exp_max
    end

    test "find empty rows and columns", fixture do
      act_empties = fixture.image
                    |> Galaxy.empties()
      assert act_empties == fixture.exp_empties
    end
  end
end
