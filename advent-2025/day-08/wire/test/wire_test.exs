defmodule WireTest do
  use ExUnit.Case
  doctest Wire

  describe "puzzle example" do
    setup do
      [
        box_positions: [
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
        exp_closest_4_boxes: [
          # 162,817,812 and 425,690,689
          {{689, 690, 425}, {812, 817, 162}},
          # 162,817,812 and 431,825,988
          {{812, 817, 162}, {988, 825, 431}},
          # 906,360,560 and 805,96,715
          {{560, 360, 906}, {715, 96, 805}},
          # 431,825,988 and 425,690,689
          {{689, 690, 425}, {988, 825, 431}}
        ],
        exp_11_circuits: %{
          # one circuit which contains 5 junction boxes
          {35, 61, 862} => {35, 61, 862},
          {344, 92, 984} => {35, 61, 862},
          {466, 650, 739} => {35, 61, 862},
          {560, 360, 906} => {35, 61, 862},
          {715, 96, 805} => {35, 61, 862},
          # one circuit which contains 4 junction boxes
          {466, 949, 346} => {689, 690, 425},
          {689, 690, 425} => {689, 690, 425},
          {812, 817, 162} => {689, 690, 425},
          {988, 825, 431} => {689, 690, 425},
          # two circuits which contain 2 junction boxes each
          {18, 987, 819} => {18, 987, 819},
          {340, 993, 941} => {18, 987, 819},
          {530, 168, 117} => {530, 168, 117},
          {668, 470, 52} => {530, 168, 117},
        },
        exp_3_largest_circuit_sizes: [
          5,
          4,
          2,
        ],
        # 216,146,977 and 117,168,530
        exp_final_connect: {{530, 168, 117}, {977, 146, 216}},
        exp_part2_product: 25272,
      ]
    end

    test "finds expected closest 4 junction boxes", fixture do
      act_closest_4_boxes =
        fixture.box_positions
        |> Wire.n_closest_box_pairs(4)
      assert act_closest_4_boxes == fixture.exp_closest_4_boxes
    end

    test "finds expected 11 circuits after making 10 connections", fixture do
      act_11_circuits =
        fixture.box_positions
        |> Wire.n_closest_box_pairs(10)
        |> Wire.connect_circuits()
      assert act_11_circuits == fixture.exp_11_circuits
    end

    test "finds expected sizes of largest 3 circuits", fixture do
      act_3_largest_circuit_sizes =
        fixture.box_positions
        |> Wire.n_closest_box_pairs(10)
        |> Wire.connect_circuits()
        |> Wire.n_largest_circuit_sizes(3)
      assert act_3_largest_circuit_sizes == fixture.exp_3_largest_circuit_sizes
    end

    test "finds final connection that makes 1 circuit from all junction boxes", fixture do
      n_boxes = Enum.count(fixture.box_positions)
      act_final_connect =
        fixture.box_positions
        |> Wire.n_closest_box_pairs(1_000_000_000_000_000)
        |> Wire.connect_all_circuits(n_boxes)
      assert act_final_connect == fixture.exp_final_connect
      assert Wire.part2_product(act_final_connect) == fixture.exp_part2_product
    end
  end
end
