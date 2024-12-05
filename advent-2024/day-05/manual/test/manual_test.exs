defmodule ManualTest do
  use ExUnit.Case
  doctest Manual

  describe "puzzle example" do
    setup do
      [
        rules: %{
          29 => [13],
          53 => [13, 29],
          61 => [29, 53, 13],
          47 => [29, 61, 13, 53],
          75 => [13, 61, 47, 53, 29],
          97 => [75, 53, 29, 47, 61, 13],
        },
        page_sets: [
          [75, 47, 61, 53, 29],
          [97, 61, 53, 29, 13],
          [75, 29, 13],
          [75, 97, 47, 61, 53],
          [61, 13, 29],
          [97, 13, 75, 29, 47],
        ],
        exp_corrects: [
          true,
          true,
          true,
          false,
          false,
          false,
        ],
        exp_middles: [
          61,
          53,
          29,
        ],
      ]
    end

    test "determine page sets with correct order", fixture do
      act_corrects =
        fixture.page_sets
        |> Enum.map(&(Manual.correct_order?(&1, fixture.rules)))
      assert act_corrects == fixture.exp_corrects
    end

    test "determine middle page of page sets with correct order", fixture do
      act_middles =
        fixture.page_sets
        |> Enum.filter(&(Manual.correct_order?(&1, fixture.rules)))
        |> Enum.map(&Manual.middle_page/1)
      assert act_middles == fixture.exp_middles
    end
  end
end
