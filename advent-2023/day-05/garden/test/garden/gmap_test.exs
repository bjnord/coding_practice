defmodule Garden.GmapTest do
  use ExUnit.Case
  doctest Garden.Gmap, import: true

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
        exp_seed_to_soil_mappings: [
          {49, 49},
          {50, 52},
          {97, 99},
          {98, 50},
          {99, 51},
          {79, 81},
          {14, 14},
          {55, 57},
          {13, 13},
        ],
        exp_locations: [
          82,
          43,
          86,
          35,
        ],
      ]
    end

    test "seed-to-soil mappings", fixture do
      {_seeds, gmaps} =
        fixture.input
        |> parse_input_string()
      assert gmaps[:seed].from == :seed
      assert gmaps[:seed].to == :soil
      fixture.exp_seed_to_soil_mappings
      |> Enum.each(fn {seed, exp_soil} ->
        act_soil = Gmap.transform(seed, gmaps[:seed])
        assert act_soil == exp_soil
      end)
    end

    test "seed locations", fixture do
      {seeds, gmaps} =
        fixture.input
        |> parse_input_string()
      act_locations =
        seeds
        |> Enum.map(fn seed -> Gmap.location(seed, gmaps) end)
      assert act_locations == fixture.exp_locations
    end
  end
end
