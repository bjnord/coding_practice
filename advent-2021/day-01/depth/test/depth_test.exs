defmodule DepthTest do
  use ExUnit.Case
  use PropCheck
  doctest Depth

  property "a single-element list has 0 increases" do
    forall list <- single_integer_list() do
      Depth.count_increases(list) == 0
    end
  end

  property "the number of increases is less than the list length" do
    forall list <- integer_list() do
      Depth.count_increases(list) < length(list)
    end
  end

  property "an always-increasing list has exactly length-1 increases" do
    forall list <- integer_list() do
      list = Enum.sort(list)
             |> Enum.dedup
      Depth.count_increases(list) == length(list) - 1
    end
  end

  property "an always-decreasing list has 0 increases" do
    forall list <- integer_list() do
      list = Enum.sort(list)
             |> Enum.reverse
             |> Enum.dedup
      Depth.count_increases(list) == 0
    end
  end

  def integer_list do
    non_empty(list(integer()))
  end

  def single_integer_list do
    vector(1, integer())
  end
end
