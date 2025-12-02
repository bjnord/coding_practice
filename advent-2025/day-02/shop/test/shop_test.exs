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
        exp_doub_counts: [
          2,
          1,
          1,
          1,
          1,
          0,
          1,
          1,
          0,
          0,
          0,
        ],
      ]
    end

    test "correctly count doubled product IDs", fixture do
      act_doub_counts = fixture.product_ranges
                        |> Enum.map(&Shop.count_doubled/1)
      assert act_doub_counts == fixture.exp_doub_counts
    end
  end
end
