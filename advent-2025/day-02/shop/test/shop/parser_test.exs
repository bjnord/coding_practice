defmodule Shop.ParserTest do
  use ExUnit.Case
  doctest Shop.Parser, import: true

  import Shop.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
        """,
        exp_product_ranges: [
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
      ]
    end

    test "parser gets expected product ranges", fixture do
      act_product_ranges =
        fixture.input
        |> parse_input_string()
      assert act_product_ranges == fixture.exp_product_ranges
    end
  end
end
