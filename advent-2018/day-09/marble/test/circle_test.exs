defmodule CircleTest do
  use ExUnit.Case
  doctest Circle

  import Circle

  test "creates the initial circle" do
    assert new() == {[0], []}
  end

  test "inserts the first marble" do
    {circle, _score} = insert(new())
    assert circle == {[1, 0], []}
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
    assert circle == {[8], [0, 7, 3, 6, 1, 5, 2, 4]}
    {circle, score} = insert(circle)
    assert score == 0
    # [9] (9) 2  5  1  6  3  7  0| 8  4
    assert circle == {[9, 2, 5, 1, 6, 3, 7, 0], [4, 8]}
  end

  test "inserts a marble (11)" do
    circle = new(10)
    # [1] (10) 5  1  6  3  7  0| 8  4  9  2
    assert circle == {[10, 5, 1, 6, 3, 7, 0], [2, 9, 4, 8]}
    {circle, score} = insert(circle)
    assert score == 0
    # [2] (11) 1  6  3  7  0| 8  4  9  2 10  5
    assert circle == {[11, 1, 6, 3, 7, 0], [5, 10, 2, 9, 4, 8]}
  end

  test "inserts a marble (23)" do
    circle = new(22)
    # [4] (22)11  1 12  6 13  3 14  7 15  0|16  8 17  4 18  9 19  2 20 10 21  5
    assert circle == {[22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0], [5, 21, 10, 20, 2, 19, 9, 18, 4, 17, 8, 16]}
    {circle, score} = insert(circle)
    assert score == 23 + 9
    # [5] (19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15  0|16  8 17  4 18
    assert circle == {[19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0], [18, 4, 17, 8, 16]}
  end

  test "inserts a marble (24)" do
    circle = new(23)
    # [5] (19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15  0|16  8 17  4 18
    assert circle == {[19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0], [18, 4, 17, 8, 16]}
    {circle, score} = insert(circle)
    assert score == 0
    # [6] (24)20 10 21  5 22 11  1 12  6 13  3 14  7 15  0|16  8 17  4 18 19  2
    assert circle == {[24, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0], [2, 19, 18, 4, 17, 8, 16]}
  end
end
