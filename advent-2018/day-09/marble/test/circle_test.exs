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
    {_circle, score} = insert(circle)
    assert score == 23 + 9
  end
end
