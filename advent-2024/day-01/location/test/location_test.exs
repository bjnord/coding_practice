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
        exp_diffs: [
          2, 1, 0, 1, 2, 5,
        ],
        exp_similarity: [
          9, 4, 0, 0, 9, 9,
        ],
      ]
    end

    test "gets expected differences", fixture do
      act_diffs = fixture.location_lists
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
