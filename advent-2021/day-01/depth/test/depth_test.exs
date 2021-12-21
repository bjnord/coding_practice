defmodule DepthTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 100]
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
             |> Enum.dedup()
      Depth.count_increases(list) == length(list) - 1
    end
  end

  property "an always-decreasing list has 0 increases" do
    forall list <- integer_list() do
      list = Enum.sort(list)
             |> Enum.reverse()
             |> Enum.dedup()
      Depth.count_increases(list) == 0
    end
  end

  property "any list has correct count of increases" do
    forall list <- integer_list() do
      Depth.count_increases(list) == alt_count_increases(list)
    end
  end

  # implementation by Brent J. Nordquist
  def alt_count_increases(list), do: alt_count_increases(0, list)
  defp alt_count_increases(n, [_]), do: n
  defp alt_count_increases(n, [head | tail]) do
    [middle | _] = tail
    n = if middle > head, do: n + 1, else: n
    alt_count_increases(n, tail)
  end

  def integer_list do
    non_empty(list(integer()))
  end

  def single_integer_list do
    vector(1, integer())
  end
end
