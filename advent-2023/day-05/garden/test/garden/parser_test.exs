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
        exp_seeds_part1: [
          {79, 1},
          {14, 1},
          {55, 1},
          {13, 1},
        ],
        exp_seeds_part2: [
          {79, 14},
          {55, 13},
        ],
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

    test "parser gets expected seeds (part 1 rules)", fixture do
      {act_seeds, _gmaps} =
        fixture.input
        |> parse_input_string(part: 1)
      assert act_seeds == fixture.exp_seeds_part1
    end

    test "parser gets expected seeds (part 2 rules)", fixture do
      {act_seeds, _gmaps} =
        fixture.input
        |> parse_input_string(part: 2)
      assert act_seeds == fixture.exp_seeds_part2
    end

    test "parser gets expected seed Gmap", fixture do
      {_seeds, act_gmaps} =
        fixture.input
        |> parse_input_string()
      assert act_gmaps[:seed] == fixture.exp_seed_gmap
    end
  end
end
