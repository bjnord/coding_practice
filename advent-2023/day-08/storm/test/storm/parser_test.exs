defmodule Storm.ParserTest do
  use ExUnit.Case
  doctest Storm.Parser, import: true

  import Storm.Parser
  alias Storm.Map

  describe "puzzle example" do
    setup do
      [
        inputs: [
          """
          RL

          AAA = (BBB, CCC)
          BBB = (DDD, EEE)
          CCC = (ZZZ, GGG)
          DDD = (DDD, DDD)
          EEE = (EEE, EEE)
          GGG = (GGG, GGG)
          ZZZ = (ZZZ, ZZZ)
          """,
          """
          LLR

          AAA = (BBB, BBB)
          BBB = (AAA, ZZZ)
          ZZZ = (ZZZ, ZZZ)
          """,
          """
          LR

          11A = (11B, XXX)
          11B = (XXX, 11Z)
          11Z = (11B, XXX)
          22A = (22B, XXX)
          22B = (22C, 22C)
          22C = (22Z, 22Z)
          22Z = (22B, 22B)
          XXX = (XXX, XXX)
          """,
        ],
        exp_maps: [
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
      ]
    end

    test "parser gets expected maps", fixture do
      act_maps = fixture.inputs
                 |> Enum.map(fn input -> parse_input_string(input) end)
      assert act_maps == fixture.exp_maps
    end
  end
end
