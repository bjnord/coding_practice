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
