defmodule LocationTest do
  use ExUnit.Case
  doctest Location

  import Location

  describe "puzzle example" do
    setup do
      [
        location_lists: {
          [3, 4, 2, 1, 3, 3],
          [4, 3, 5, 3, 9, 3],
        },
        exp_sorted_locations: [
          {1, 3},
          {2, 3},
          {3, 3},
          {3, 4},
          {3, 5},
          {4, 9},
        ],
        exp_diffs: [
          2, 1, 0, 1, 2, 5,
        ],
        exp_similarity: [
          9, 4, 0, 0, 9, 9,
        ],
      ]
    end

    test "gets expected sorted location lists", fixture do
      act_sorted_lists = fixture.location_lists
                         |> sort_location_lists()
      assert act_sorted_lists == fixture.exp_sorted_locations
    end

    test "gets expected differences", fixture do
      act_diffs = fixture.exp_sorted_locations
                  |> location_pair_diff()
      assert act_diffs == fixture.exp_diffs
    end

    test "gets expected similarity", fixture do
      act_similarity = fixture.location_lists
                       |> similarity()
      assert act_similarity == fixture.exp_similarity
    end
  end
end
