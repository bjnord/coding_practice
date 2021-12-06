defmodule LanternfishTest do
  use ExUnit.Case
  doctest Lanternfish

  describe "puzzle example" do
    setup do
      [
        fish: [3, 4, 3, 1, 2],
        buckets_0: {0, 1, 1, 2, 1, 0, 0, 0, 0},
        buckets_18: {3, 5, 3, 2, 2, 1, 5, 1, 4},
        buckets_80_count: 5934,
        buckets_256_count: 26984457539,
      ]
    end

    test "bucketizer", fixture do
      assert Lanternfish.to_buckets(fixture.fish) == fixture.buckets_0
    end

    test "generator produces expected buckets", fixture do
      assert Lanternfish.generate(fixture.buckets_0, 18) == fixture.buckets_18
      act_80_count = Lanternfish.generate(fixture.buckets_0, 80)
                     |> Tuple.to_list()
                     |> Enum.sum()
      assert act_80_count == fixture.buckets_80_count
      act_256_count = Lanternfish.generate(fixture.buckets_0, 256)
                      |> Tuple.to_list()
                      |> Enum.sum()
      assert act_256_count == fixture.buckets_256_count
    end
  end
end
