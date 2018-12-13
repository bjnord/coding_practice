defmodule MineCartTest do
  use ExUnit.Case
  doctest MineCart

  test "cart sorting" do
    carts = [
      {{0, 10}, :down, :left},
      {{2, 8}, :up, :left},
      {{0, 9}, :right, :left},
      {{2, 7}, :left, :left},
      {{1, 6}, :left, :left},
    ]
    assert Enum.sort(carts, &(elem(&1, 0) <= elem(&2, 0))) == [
      {{0, 9}, :right, :left},
      {{0, 10}, :down, :left},
      {{1, 6}, :left, :left},
      {{2, 7}, :left, :left},
      {{2, 8}, :up, :left},
    ]
  end
end
