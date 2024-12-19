defmodule Onsen.ParserTest do
  use ExUnit.Case
  doctest Onsen.Parser, import: true

  import Onsen.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        r, wr, b, g, bwu, rb, gb, br

        brwrr
        bggr
        gbbr
        rrbgbr
        ubwu
        bwurrg
        brgr
        bbrgwb
        """,
        exp_part_1: {
          %{
            ?r => %{
              ?. => true,
              ?b => %{
                ?. => true,
              },
            },
            ?g => %{
              ?. => true,
              ?b => %{
                ?. => true,
              },
            },
            ?b => %{
              ?. => true,
              ?r => %{
                ?. => true,
              },
              ?w => %{
                ?u => %{
                  ?. => true,
                },
              },
            },
            ?w => %{
              ?r => %{
                ?. => true,
              },
            },
          },
          [
            [?b, ?r, ?w, ?r, ?r],
            [?b, ?g, ?g, ?r],
            [?g, ?b, ?b, ?r],
            [?r, ?r, ?b, ?g, ?b, ?r],
            [?u, ?b, ?w, ?u],
            [?b, ?w, ?u, ?r, ?r, ?g],
            [?b, ?r, ?g, ?r],
            [?b, ?b, ?r, ?g, ?w, ?b],
          ],
        },
        exp_part_2: {
          MapSet.new([
            "r",
            "wr",
            "b",
            "g",
            "bwu",
            "rb",
            "gb",
            "br",
          ]),
          [
            "brwrr",
            "bggr",
            "gbbr",
            "rrbgbr",
            "ubwu",
            "bwurrg",
            "brgr",
            "bbrgwb",
          ],
        },
      ]
    end

    test "parser gets expected result (part 1)", fixture do
      act_part_1 = fixture.input
                   |> parse_input_string()
      assert act_part_1 == fixture.exp_part_1
    end

    test "parser gets expected result (part 2)", fixture do
      act_part_2 = fixture.input
                   |> parse2_input_string()
      assert act_part_2 == fixture.exp_part_2
    end
  end
end
