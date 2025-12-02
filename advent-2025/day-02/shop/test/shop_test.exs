defmodule ShopTest do
  use ExUnit.Case
  doctest Shop

  describe "puzzle example" do
    setup do
      [
        product_ranges: [
          {11, 22},
          {95, 115},
          {998, 1012},
          {1188511880, 1188511890},
          {222220, 222224},
          {1698522, 1698528},
          {446443, 446449},
          {38593856, 38593862},
          {565653, 565659},
          {824824821, 824824827},
          {2121212118, 2121212124},
        ],
        exp_doub_sums: [
          33,
          99,
          1010,
          1188511885,
          222222,
          0,
          446446,
          38593859,
          0,
          0,
          0,
        ],
      ]
    end

    test "correctly sum doubled product IDs", fixture do
      act_doub_sums = fixture.product_ranges
                      |> Enum.map(&Shop.sum_doubled/1)
      assert act_doub_sums == fixture.exp_doub_sums
    end
  end
end
