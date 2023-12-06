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
        exp_seed_to_soil_mappings_part1: [
          {{49, 1}, [{49, 1}]},
          {{50, 1}, [{52, 1}]},
          {{97, 1}, [{99, 1}]},
          {{98, 1}, [{50, 1}]},
          {{99, 1}, [{51, 1}]},
          {{79, 1}, [{81, 1}]},
          {{14, 1}, [{14, 1}]},
          {{55, 1}, [{57, 1}]},
          {{13, 1}, [{13, 1}]},
        ],
        exp_min_location_part1: 35,
        exp_seed_to_soil_mappings_part2: [
          {{96, 4}, [{98, 2}, {50, 2}]},
          # values before earliest range:
          {{48, 2}, [{48, 2}]},
          {{48, 4}, [{48, 2}, {52, 2}]},
          # values after latest range:
          {{96, 6}, [{98, 2}, {50, 2}, {100, 2}]},
          {{100, 2}, [{100, 2}]},
        ],
        input_notch_part2: """
        seed-to-soil map:
        30 40 7
        60 50 7
        """,
        notch_range_part2: {44, 9},
        exp_notch_mappings_part2: [
          {34, 3},
          {47, 3},
          {60, 3},
        ],
        exp_min_location_part2: 46,
      ]
    end

    test "seed-to-soil mappings (part 1)", fixture do
      {_seeds, gmaps} =
        fixture.input
        |> parse_input_string(part: 1)
      assert gmaps[:seed].from == :seed
      assert gmaps[:seed].to == :soil
      fixture.exp_seed_to_soil_mappings_part1
      |> Enum.each(fn {{seed, length}, exp_soil} ->
        act_soil = Gmap.transform({seed, length}, gmaps[:seed])
        assert act_soil == exp_soil
      end)
    end

    test "seed locations (part 1)", fixture do
      {seeds, gmaps} =
        fixture.input
        |> parse_input_string(part: 1)
      act_min_locations =
        seeds
        |> Enum.map(fn seed -> Gmap.min_location(seed, gmaps) end)
        |> Enum.min()
      assert act_min_locations == fixture.exp_min_location_part1
    end

    test "seed-to-soil mappings (part 2)", fixture do
      {_seeds, gmaps} =
        fixture.input
        |> parse_input_string(part: 2)
      assert gmaps[:seed].from == :seed
      assert gmaps[:seed].to == :soil
      fixture.exp_seed_to_soil_mappings_part2
      |> Enum.each(fn {{seed, length}, exp_soil} ->
        act_soil = Gmap.transform({seed, length}, gmaps[:seed])
        assert act_soil == exp_soil
      end)
    end

    test "seed-to-soil mappings with notch (part 2)", fixture do
      gmap =
        fixture.input_notch_part2
        |> parse_gmap_block()
      act_mappings =
        Gmap.transform(fixture.notch_range_part2, gmap)
      assert act_mappings == fixture.exp_notch_mappings_part2
    end

    test "seed min location (part 2)", fixture do
      {seeds, gmaps} =
        fixture.input
        |> parse_input_string(part: 2)
      act_min_location =
        seeds
        |> Enum.map(fn seed -> Gmap.min_location(seed, gmaps) end)
        |> Enum.min()
      assert act_min_location == fixture.exp_min_location_part2
    end
  end
end
