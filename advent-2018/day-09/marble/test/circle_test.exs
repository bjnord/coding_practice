defmodule CircleTest do
  use ExUnit.Case
  doctest Circle

  import Circle

  test "creates the initial circle" do
    assert new() == {[0], [], 0}
  end

  test "inserts the first marble" do
    {circle, _score} = insert(new())
    assert circle == {[1, 0], [], 1}
  end

  test "inserts a marble (non-23)" do
    1..22
    |> Enum.reduce(new(), fn (_n, circle) ->
      {circle, score} = insert(circle)
      assert score == 0
      circle
    end)
  end

  test "inserts a marble (9)" do
    circle = new(8)
    # [8] (8)|4  2  5  1  6  3  7  0
    assert circle == {[8], [0, 7, 3, 6, 1, 5, 2, 4], 8}
    {circle, score} = insert(circle)
    assert score == 0
    # [9] (9) 2  5  1  6  3  7  0| 8  4
    assert circle == {[9, 2, 5, 1, 6, 3, 7, 0], [4, 8], 9}
  end

  test "inserts a marble (11)" do
    circle = new(10)
    # [1] (10) 5  1  6  3  7  0| 8  4  9  2
    assert circle == {[10, 5, 1, 6, 3, 7, 0], [2, 9, 4, 8], 10}
    {circle, score} = insert(circle)
    assert score == 0
    # [2] (11) 1  6  3  7  0| 8  4  9  2 10  5
    assert circle == {[11, 1, 6, 3, 7, 0], [5, 10, 2, 9, 4, 8], 11}
  end

  test "inserts a marble (23)" do
    circle = new(22)
    # [4] (22)11  1 12  6 13  3 14  7 15  0|16  8 17  4 18  9 19  2 20 10 21  5
    assert circle == {[22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0], [5, 21, 10, 20, 2, 19, 9, 18, 4, 17, 8, 16], 22}
    {circle, score} = insert(circle)
    assert score == 23 + 9
    # [5] (19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15  0|16  8 17  4 18
    assert circle == {[19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0], [18, 4, 17, 8, 16], 23}
  end

  # this covers the case when the back list doesn't have 7+ marbles for a
  # 23-marble insert -- note that back will never have fewer than 2, so
  # this tests the edge case
  test "inserts a marble (23) [contrived state]" do
    circle = {[22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0, 16, 8, 17, 4, 18, 9, 19, 2, 20, 10], [5, 21], 22}
    {circle, score} = insert(circle)
    assert score == 23 + 9
    # [5] (19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15  0|16  8 17  4 18
    assert circle == {[19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0, 16, 8, 17, 4, 18], [], 23}
  end

  test "inserts a marble (24)" do
    circle = new(23)
    # [5] (19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15  0|16  8 17  4 18
    assert circle == {[19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0], [18, 4, 17, 8, 16], 23}
    {circle, score} = insert(circle)
    assert score == 0
    # [6] (24)20 10 21  5 22 11  1 12  6 13  3 14  7 15  0|16  8 17  4 18 19  2
    assert circle == {[24, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0], [2, 19, 18, 4, 17, 8, 16], 24}
  end

  # this double-checks what happens after our non 7+ marbles insertion
  test "inserts a marble (24) [contrived state]" do
    circle = {[19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0, 16, 8, 17, 4, 18], [], 23}
    {circle, score} = insert(circle)
    assert score == 0
    # [6] (24)20 10 21  5 22 11  1 12  6 13  3 14  7 15  0|16  8 17  4 18 19  2
    assert circle == {[24, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0, 16, 8, 17, 4, 18], [2, 19], 24}
  end

  test "inserts a marble (46)" do
    circle = new(45)
    assert circle == {[45, 2, 24, 20, 25, 10, 26, 21, 27, 5, 28, 22, 29, 11, 30, 1, 31, 12, 32, 6, 33, 13, 34, 3, 35, 14, 36, 7, 37, 15, 38, 0], [19, 44, 18, 43, 4, 42, 17, 41, 8, 40, 16, 39], 45}
    {circle, score} = insert(circle)
    assert score == 63
    assert circle == {[42, 4, 43, 18, 44, 19, 45, 2, 24, 20, 25, 10, 26, 21, 27, 5, 28, 22, 29, 11, 30, 1, 31, 12, 32, 6, 33, 13, 34, 3, 35, 14, 36, 7, 37, 15, 38, 0], [41, 8, 40, 16, 39], 46}
  end
end
