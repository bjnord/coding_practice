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
  end
end
