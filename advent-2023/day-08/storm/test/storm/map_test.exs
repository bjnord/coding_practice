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
      ]
    end

    test "find steps", fixture do
      act_steps = fixture.maps
                  |> Enum.map(&Map.steps/1)
      assert act_steps == fixture.exp_steps
    end
  end
end
