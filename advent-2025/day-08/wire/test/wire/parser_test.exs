defmodule Wire.ParserTest do
  use ExUnit.Case
  doctest Wire.Parser, import: true

  import Wire.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        162,817,812
        57,618,57
        906,360,560
        592,479,940
        352,342,300
        466,668,158
        542,29,236
        431,825,988
        739,650,466
        52,470,668
        216,146,977
        819,987,18
        117,168,530
        805,96,715
        346,949,466
        970,615,88
        941,993,340
        862,61,35
        984,92,344
        425,690,689
        """,
        exp_box_positions: [
          {812, 817, 162},
          {57, 618, 57},
          {560, 360, 906},
          {940, 479, 592},
          {300, 342, 352},
          {158, 668, 466},
          {236, 29, 542},
          {988, 825, 431},
          {466, 650, 739},
          {668, 470, 52},
          {977, 146, 216},
          {18, 987, 819},
          {530, 168, 117},
          {715, 96, 805},
          {466, 949, 346},
          {88, 615, 970},
          {340, 993, 941},
          {35, 61, 862},
          {344, 92, 984},
          {689, 690, 425},
        ],
      ]
    end

    test "parser gets expected junction box positions", fixture do
      act_box_positions =
        fixture.input
        |> parse_input_string()
      assert act_box_positions == fixture.exp_box_positions
    end
  end
end
