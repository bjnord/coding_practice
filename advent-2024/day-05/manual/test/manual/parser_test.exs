defmodule Manual.ParserTest do
  use ExUnit.Case
  doctest Manual.Parser, import: true

  import Manual.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        47|53
        97|13
        97|61
        97|47
        75|29
        61|13
        75|53
        29|13
        97|29
        53|29
        61|53
        97|53
        61|29
        47|13
        75|47
        97|75
        47|61
        75|61
        47|29
        75|13
        53|13

        75,47,61,53,29
        97,61,53,29,13
        75,29,13
        75,97,47,61,53
        61,13,29
        97,13,75,29,47
        """,
        exp_rules: %{
          29 => [13],
          53 => [13, 29],
          61 => [29, 53, 13],
          47 => [29, 61, 13, 53],
          75 => [13, 61, 47, 53, 29],
          97 => [75, 53, 29, 47, 61, 13],
        },
        exp_page_sets: [
          [75, 47, 61, 53, 29],
          [97, 61, 53, 29, 13],
          [75, 29, 13],
          [75, 97, 47, 61, 53],
          [61, 13, 29],
          [97, 13, 75, 29, 47],
        ],
      ]
    end

    test "parser gets expected rules and page sets", fixture do
      {act_rules, act_page_sets} =
        fixture.input
        |> parse_input_string()
      assert act_rules == fixture.exp_rules
      assert act_page_sets == fixture.exp_page_sets
    end
  end
end
