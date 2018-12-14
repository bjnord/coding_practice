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

  test "cart turning (intersection)" do
    grid = %{{1, 1} => :intersect}
    assert MineCart.turn_cart({{1, 1}, :up, :left}, grid) ==
      {{1, 1}, :left, :straight}
    assert MineCart.turn_cart({{1, 1}, :down, :left}, grid) ==
      {{1, 1}, :right, :straight}
    assert MineCart.turn_cart({{1, 1}, :left, :straight}, grid) ==
      {{1, 1}, :left, :right}
    assert MineCart.turn_cart({{1, 1}, :down, :right}, grid) ==
      {{1, 1}, :left, :left}
    assert MineCart.turn_cart({{1, 1}, :left, :right}, grid) ==
      {{1, 1}, :up, :left}
  end

  test "cart turning (curve)" do
    grid = %{{1, 1} => :curve_ne}
    assert MineCart.turn_cart({{1, 1}, :left, :straight}, grid) ==
      {{1, 1}, :down, :straight}
    assert MineCart.turn_cart({{1, 1}, :up, :straight}, grid) ==
      {{1, 1}, :right, :straight}

    grid = %{{1, 1} => :curve_nw}
    assert MineCart.turn_cart({{1, 1}, :right, :straight}, grid) ==
      {{1, 1}, :down, :straight}
    assert MineCart.turn_cart({{1, 1}, :up, :straight}, grid) ==
      {{1, 1}, :left, :straight}

  end

  test "cart turning (straight)" do
    grid = %{{1, 1} => :horiz}
    assert MineCart.turn_cart({{1, 1}, :left, :straight}, grid) ==
      {{1, 1}, :left, :straight}

    grid = %{{1, 1} => :vert}
    assert MineCart.turn_cart({{1, 1}, :down, :straight}, grid) ==
      {{1, 1}, :down, :straight}
  end
end
