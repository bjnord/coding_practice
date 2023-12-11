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
        exp_expanded: [
          {0, 4},
          {1, 9},
          {2, 0},
          {5, 8},
          {6, 1},
          {7, 12},
          {10, 9},
          {11, 0},
          {11, 5},
        ],
        exp_path_length: 374,
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

    test "expand image", fixture do
      act_expanded = fixture.image
                     |> Galaxy.expand()
      assert act_expanded == fixture.exp_expanded
    end

    test "calculate total path length", fixture do
      act_path_length = fixture.image
                        |> Galaxy.path_length()
      assert act_path_length == fixture.exp_path_length
    end
  end
end
