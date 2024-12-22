defmodule MonkeyTest do
  use ExUnit.Case
  doctest Monkey, import: true

  describe "puzzle examples" do
    setup do
      [
        secret_number: 123,
        exp_next_numbers: [
          15887950,
          16495136,
          527345,
          704524,
          1553684,
          12683156,
          11100544,
          12249484,
          7753432,
          5908254,
        ],
        secret_numbers: [
          1,
          10,
          100,
          2024,
        ],
        exp_2000th_numbers: [
          8685429,
          4700978,
          15273692,
          8667524,
        ],
      ]
    end

    test "calculate correct next secret numbers", fixture do
      act_next_numbers = fixture.secret_number
                         |> Monkey.next_numbers(10)
      assert act_next_numbers == fixture.exp_next_numbers
    end

    test "calculate buyer 2000th secret numbers", fixture do
      act_2000th_numbers = fixture.secret_numbers
                           |> Monkey.nth_buyer_numbers(2000)
      assert act_2000th_numbers == fixture.exp_2000th_numbers
    end
  end
end
