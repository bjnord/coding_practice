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
        exp_config: {
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
      ]
    end

    test "parser gets expected configuration", fixture do
      act_config = fixture.input
                   |> parse_input_string()
      assert act_config == fixture.exp_config
    end
  end
end
