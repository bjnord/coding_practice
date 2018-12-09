defmodule TreeTest do
  use ExUnit.Case
  doctest Tree

  import Tree

  test "parses string to integers" do
    assert parse_integers("1 5 2 4 3\n") == [1, 5, 2, 4, 3]
  end

  test "transforms input to tree structure (metas only)" do
    assert build_tree([0, 1, 7]) == {%{}, [7]}
    assert build_tree([0, 2, 19, 26]) == {%{}, [19, 26]}
  end

  test "transforms input to tree structure (with children)" do
    assert build_tree([1, 1, 0, 1, 3, 5]) == {
      %{1 => {%{}, [3]}},
      [5]
    }
    assert build_tree([1, 2, 0, 3, 11, 12, 13, 25, 26]) == {
      %{1 => {%{}, [11, 12, 13]}},
      [25, 26]
    }
  end

  test "transforms input to tree structure (problem example)" do
    example1 = [2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]
    assert build_tree(example1) == {
      %{
        1 => {%{}, [10, 11, 12]},
        2 => {
          %{1 => {%{}, [99]}},
          [2]
        }
      },
      [1, 1, 2]
    }
  end
end
