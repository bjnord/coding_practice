defmodule CircleTest do
  use ExUnit.Case
  doctest Circle

  import Circle

  test "creates the initial circle" do
    circle = new(100)
    assert to_list(circle) == [0]
    assert latest(circle) == 0
  end

  test "inserts the first marble" do
    {circle, _score} = insert(new(100))
    assert to_list(circle) == [1, 0]
    assert latest(circle) == 1
  end

  test "inserts a marble (2)" do
    {circle, score} = insert(new(100, 1))
    assert score == 0
    # [2] (2) 1  0
    assert to_list(circle) == [2, 1, 0]
    assert latest(circle) == 2
  end

  test "inserts marbles 1-22 (check 0 score)" do
    1..22
    |> Enum.reduce(new(100), fn (_n, circle) ->
      {circle, score} = insert(circle)
      assert score == 0
      circle
    end)
  end

  test "inserts a marble (9)" do
    {circle, score} = insert(new(100, 8))
    assert score == 0
    # [9] (9) 2  5  1  6  3  7  0  8  4
    assert to_list(circle) == [9, 2, 5, 1, 6, 3, 7, 0, 8, 4]
    assert latest(circle) == 9
  end

  test "inserts a marble (11)" do
    {circle, score} = insert(new(100, 10))
    assert score == 0
    # [2] (11) 1  6  3  7  0  8  4  9  2 10  5
    assert to_list(circle) == [11, 1, 6, 3, 7, 0, 8, 4, 9, 2, 10, 5]
    assert latest(circle) == 11
  end

  test "inserts a marble (23)" do
    {circle, score} = insert(new(100, 22))
    assert score == 23 + 9
    # [5] (19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15  0 16  8 17  4 18
    assert to_list(circle) == [19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0, 16, 8, 17, 4, 18]
    assert latest(circle) == 23
  end

  test "inserts a marble (24)" do
    {circle, score} = insert(new(100, 23))
    assert score == 0
    # [6] (24)20 10 21  5 22 11  1 12  6 13  3 14  7 15  0 16  8 17  4 18 19  2
    assert to_list(circle) == [24, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0, 16, 8, 17, 4, 18, 19, 2]
    assert latest(circle) == 24
  end

  test "inserts a marble (46)" do
    {circle, score} = insert(new(100, 45))
    assert score == 63
    assert to_list(circle) == [42, 4, 43, 18, 44, 19, 45, 2, 24, 20, 25, 10, 26, 21, 27, 5, 28, 22, 29, 11, 30, 1, 31, 12, 32, 6, 33, 13, 34, 3, 35, 14, 36, 7, 37, 15, 38, 0, 39, 16, 40, 8, 41]
    assert latest(circle) == 46
  end
end
