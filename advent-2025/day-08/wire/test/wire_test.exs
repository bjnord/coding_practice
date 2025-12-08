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
      ]
    end

    test "finds expected closest 4 junction boxes", fixture do
      act_closest_4_boxes = fixture.box_positions
                            |> Wire.n_closest_box_pairs(4)
      assert act_closest_4_boxes == fixture.exp_closest_4_boxes
    end
  end
end
