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
        exp_arrangements: [
          2,
          1,
          4,
          6,
          0,
          1,
          2,
          0,
        ]
      ]
    end

    test "finds possible towel arrangements", fixture do
      act_possibles =
        fixture.towels
        |> Enum.map(&(Onsen.possible?(&1, fixture.towel_patterns)))
      assert act_possibles == fixture.exp_possibles
    end

    test "counts all towel arrangements", fixture do
      act_arrangements =
        fixture.towels
        |> Enum.map(&(Onsen.arrangements(&1, fixture.towel_patterns)))
      assert act_arrangements == fixture.exp_arrangements
    end
  end
end
