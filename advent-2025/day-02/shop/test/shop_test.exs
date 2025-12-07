defmodule ShopTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 100]
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
        exp_rep_sums: [
          33,
          210,
          2009,
          1188511885,
          222222,
          0,
          446446,
          38593859,
          565656,
          824824824,
          2121212121,
        ],
      ]
    end

    test "correctly sum doubled product IDs", fixture do
      act_doub_sums =
        fixture.product_ranges
        |> Enum.map(&Shop.sum_doubled/1)
      assert act_doub_sums == fixture.exp_doub_sums
    end

    test "correctly sum repeated product IDs", fixture do
      act_rep_sums =
        fixture.product_ranges
        |> Enum.map(&Shop.sum_repeated/1)
      assert act_rep_sums == fixture.exp_rep_sums
    end
  end

  ###
  # Property-Based Tests
  #
  # with help from Fred Hebert's book,
  # [Property-Based Testing with PropEr, Erlang, and Elixir](https://pragprog.com/titles/fhproper)
  #
  # Published: Jan 2019, Pragmatic Programmers
  # ISBN: 9781680506211

  ###
  # Properties

  property "repeating patterns are detected" do
    forall id <- gen_repeated_string() do
      String.to_integer(id)
      |> Shop.slow_is_repeated?()
    end
  end

  property "non-repeating patterns aren't detected" do
    forall id <- gen_nonrepeated_string() do
      String.to_integer(id)
      |> Shop.slow_is_repeated?()
      |> then(fn b -> !b end)
    end
  end

  # make verbose for metrics
  property "repeated ID statistics", [:verbose] do
    forall id <- gen_repeated_string() do
      collect(true, to_size_range(10, byte_size(id), "product ID size"))
    end
  end

  property "slow and fast part 1 designs produce identical results" do
    forall range <- gen_range() do
      Shop.sum_doubled(range) == Shop.slow_sum_doubled(range)
    end
  end

  property "slow and fast part 2 designs produce identical results" do
    forall range <- gen_range() do
      Shop.sum_repeated(range) == Shop.slow_sum_repeated(range)
    end
  end

  # make verbose for metrics
  property "range statistics", [:verbose] do
    forall range <- gen_range() do
      collect(true, {"range hi size", Decor.Math.n_digits(elem(range, 1))})
    end
  end

  ###
  # Helpers

  def to_size_range(m, n, label) do
    base = div(n, m)
    {label, {base * m, (base + 1) * m}}
  end

  ###
  # Generators

  def gen_id_pattern() do
    # resize so we get some 3- and 4-char patterns
    sized(s, resize(s * 17, pos_integer()))
  end

  def gen_repeated_string() do
    let {rep, patt} <- {range(2, 9), gen_id_pattern()} do
      Integer.to_string(patt)
      |> String.duplicate(rep)
    end
  end

  def gen_nonrepeated_string() do
    let id <- gen_repeated_string() do
      # corrupt the pattern by decrementing any but the leading digit
      delta = 10 ** (:rand.uniform(byte_size(id) - 1) - 1)
      (String.to_integer(id) - delta)
      |> Integer.to_string()
    end
  end

  def gen_range() do
    # **NOTE** `resize(s ** 4)` produces a much more comprehensive test
    # (the ranges used include some 8-digit numbers), but then `make test`
    # is reeeeallllyyy sllloooooowwww. `resize(s ** 3)` is a reasonable
    # compromise (6-digit numbers).
    let {lo, n} <- {sized(s, resize(s ** 3, pos_integer())), sized(s, resize(s ** 3, pos_integer()))} do
      {lo, lo + n}
    end
  end
end
