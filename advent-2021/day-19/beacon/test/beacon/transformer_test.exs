defmodule Beacon.TransformerTest do
  use ExUnit.Case
  doctest Beacon.Transformer

  alias Beacon.Transformer, as: Transformer

  describe "transformations" do
    test "transformer produces 24 unique transformations" do
      act_count =
        Transformer.transforms({3, 11, 103})
        |> Enum.uniq()
        |> Enum.count()
      assert act_count == 24
    end

    test "transformer same-as are same as transform" do
      pos = {3, 11, 103}
      1..6
      |> Enum.each(fn n ->
        base_pos = Transformer.transform(pos, n)
        Transformer.same_as(pos, n)
        |> Enum.each(fn same_pos ->
          assert same_pos == base_pos
        end)
      end)
    end
  end
end
