defmodule LocationTest do
  use ExUnit.Case
  doctest Location

  import Location

  describe "puzzle example" do
    setup do
      [
        locations: [
          {3, 4},
          {4, 3},
          {2, 5},
          {1, 3},
          {3, 9},
          {3, 3},
        ],
        exp_sorted_loc: [
          {1, 3},
          {2, 3},
          {3, 3},
          {3, 4},
          {3, 5},
          {4, 9},
        ],
        exp_diffs: [
          2,
          1,
          0,
          1,
          2,
          5,
        ],
        exp_similarity: [
          9,
          4,
          0,
          0,
          9,
          9,
        ],
      ]
    end

    test "gets expected sorted columns", fixture do
      act_sorted_loc = fixture.locations
                       |> sort_columns()
      assert act_sorted_loc == fixture.exp_sorted_loc
    end

    test "gets expected differences", fixture do
      act_diffs = fixture.exp_sorted_loc
                  |> pair_diff()
      assert act_diffs == fixture.exp_diffs
    end

    test "gets expected similarity", fixture do
      act_similarity = fixture.locations
                       |> similarity()
      assert act_similarity == fixture.exp_similarity
    end
  end
end
