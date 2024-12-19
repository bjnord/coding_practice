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
      ]
    end

    test "finds possible towel arrangements", fixture do
      act_possibles =
        fixture.towels
        |> Enum.map(&(Onsen.possible?(&1, fixture.towel_patterns)))
      assert act_possibles == fixture.exp_possibles
    end
  end
end
