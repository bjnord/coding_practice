defmodule OnsenTest do
  use ExUnit.Case
  doctest Onsen

  describe "puzzle example" do
    setup do
      [
        towel_patterns: %{
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
        towels: [
          [?b, ?r, ?w, ?r, ?r],
          [?b, ?g, ?g, ?r],
          [?g, ?b, ?b, ?r],
          [?r, ?r, ?b, ?g, ?b, ?r],
          [?u, ?b, ?w, ?u],
          [?b, ?w, ?u, ?r, ?r, ?g],
          [?b, ?r, ?g, ?r],
          [?b, ?b, ?r, ?g, ?w, ?b],
        ],
        exp_possibles: [
          true,
          true,
          true,
          true,
          false,
          true,
          true,
          false,
        ],
        towel2_patterns: MapSet.new([
          "r",
          "wr",
          "b",
          "g",
          "bwu",
          "rb",
          "gb",
          "br",
        ]),
        towels2: [
          "brwrr",
          "bggr",
          "gbbr",
          "rrbgbr",
          "ubwu",
          "bwurrg",
          "brgr",
          "bbrgwb",
        ],
        division_tests: [
          {{"r", 1}, 1},
          {{"r", 2}, 1},
          #
          {{"rb", 1}, 1},  # 11
          {{"rb", 2}, 1 + 1},  # + 2
          {{"rb", 3}, 1 + 1},
          #
          {{"bggr", 2}, 5},  # 22, 211, 121, 112, 1111
          {{"bggr", 3}, 5 + 2},  # + 31, 13
          {{"bggr", 4}, 5 + 2 + 1},  # + 4
          {{"bggr", 5}, 5 + 2 + 1},
        ],
        exp_arrangements: [
          2,
          1,
          4,
          6,
          0,
          1,
          2,
          0,
        ],
      ]
    end

    test "finds possible towel arrangements (part 1)", fixture do
      act_possibles =
        fixture.towels
        |> Enum.map(&(Onsen.possible?(&1, fixture.towel_patterns)))
      assert act_possibles == fixture.exp_possibles
    end

    test "finds all possible divisions of towel (part 2)", fixture do
      fixture.division_tests
      |> Enum.each(fn {{towel, max_chunk}, exp_divisions} ->
        act_divisions =
          Onsen.divisions(towel, max_chunk)
          |> Enum.count()
        assert act_divisions == exp_divisions
      end)
    end

    test "counts all towel arrangements (part 2)", fixture do
      act_arrangements =
        fixture.towels2
        |> Enum.map(&(Onsen.arrangements(&1, fixture.towel2_patterns)))
      assert act_arrangements == fixture.exp_arrangements
    end
  end
end
