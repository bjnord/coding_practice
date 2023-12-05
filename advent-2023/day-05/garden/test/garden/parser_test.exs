defmodule Garden.ParserTest do
  use ExUnit.Case
  doctest Garden.Parser, import: true

  import Garden.Parser
  alias Garden.Gmap

  describe "puzzle example" do
    setup do
      [
        input: """
        seeds: 79 14 55 13

        seed-to-soil map:
        50 98 2
        52 50 48

        soil-to-fertilizer map:
        0 15 37
        37 52 2
        39 0 15

        fertilizer-to-water map:
        49 53 8
        0 11 42
        42 0 7
        57 7 4

        water-to-light map:
        88 18 7
        18 25 70

        light-to-temperature map:
        45 77 23
        81 45 19
        68 64 13

        temperature-to-humidity map:
        0 69 1
        1 0 69

        humidity-to-location map:
        60 56 37
        56 93 4
        """,
        exp_seeds: [ 79, 14, 55, 13 ],
        exp_seed_gmap: %Gmap{
          from: :seed,
          to: :soil,
          maps: [
            %{
              to: 50,
              from: 98,
              length: 2,
            },
            %{
              to: 52,
              from: 50,
              length: 48,
            },
          ],
        }
      ]
    end

    test "parser gets expected seeds and maps", fixture do
      {act_seeds, act_gmaps} =
        fixture.input
        |> parse_input_string()
      assert act_seeds == fixture.exp_seeds
      assert List.first(act_gmaps) == fixture.exp_seed_gmap
    end
  end
end
