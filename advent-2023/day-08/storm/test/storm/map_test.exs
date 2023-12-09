defmodule Storm.MapTest do
  use ExUnit.Case
  doctest Storm.Map, import: true

  alias Storm.Map

  describe "puzzle example" do
    setup do
      [
        maps: [
          %Map{
            dirs: [:right, :left],
            nodes: %{
              "AAA" => {"BBB", "CCC"},
              "BBB" => {"DDD", "EEE"},
              "CCC" => {"ZZZ", "GGG"},
              "DDD" => {"DDD", "DDD"},
              "EEE" => {"EEE", "EEE"},
              "GGG" => {"GGG", "GGG"},
              "ZZZ" => {"ZZZ", "ZZZ"},
            },
          },
          %Map{
            dirs: [:left, :left, :right],
            nodes: %{
              "AAA" => {"BBB", "BBB"},
              "BBB" => {"AAA", "ZZZ"},
              "ZZZ" => {"ZZZ", "ZZZ"},
            },
          },
        ],
        exp_steps: [2, 6],
        maps_part2: [
          %Map{
            dirs: [:left, :right],
            nodes: %{
              "11A" => {"11B", "XXX"},
              "11B" => {"XXX", "11Z"},
              "11Z" => {"11B", "XXX"},
              "22A" => {"22B", "XXX"},
              "22B" => {"22C", "22C"},
              "22C" => {"22Z", "22Z"},
              "22Z" => {"22B", "22B"},
              "XXX" => {"XXX", "XXX"},
            },
          },
        ],
        exp_a_nodes_part2: [["11A", "22A"]],
        exp_cycle_lengths_part2: [
          %{"11A" => 2, "22A" => 3},
        ],
      ]
    end

    test "find steps (part 1)", fixture do
      act_steps = fixture.maps
                  |> Enum.map(&Map.steps/1)
      assert act_steps == fixture.exp_steps
    end

    test "find A nodes (part 2)", fixture do
      act_a_nodes = fixture.maps_part2
                    |> Enum.map(&Map.a_nodes/1)
      assert act_a_nodes == fixture.exp_a_nodes_part2
    end

    test "find A node cycle lengths (part 2)", fixture do
      act_cycle_lengths = fixture.maps_part2
                          |> Enum.map(fn map ->
                            Map.a_nodes(map)
                            |> Enum.map(fn node -> {node, Map.cycle_length(map, node)} end)
                            |> Enum.into(%{})
                          end)
      assert act_cycle_lengths == fixture.exp_cycle_lengths_part2
    end
  end
end
