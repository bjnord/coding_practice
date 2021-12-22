defmodule Reactor.CuboidTest do
  use ExUnit.Case
  doctest Reactor.Cuboid

  alias Reactor.Cuboid, as: Cuboid
  alias Reactor.Parser, as: Parser

  describe "puzzle example" do
    setup do
      [
        larger_input: """
        on x=-20..26,y=-36..17,z=-47..7
        on x=-20..33,y=-21..23,z=-26..28
        on x=-22..28,y=-29..23,z=-38..16
        on x=-46..7,y=-6..46,z=-50..-1
        on x=-49..1,y=-3..46,z=-24..28
        on x=2..47,y=-22..22,z=-23..27
        on x=-27..23,y=-28..26,z=-21..29
        on x=-39..5,y=-6..47,z=-3..44
        on x=-30..21,y=-8..43,z=-13..34
        on x=-22..26,y=-27..20,z=-29..19
        off x=-48..-32,y=26..41,z=-47..-37
        on x=-12..35,y=6..50,z=-50..-2
        off x=-48..-32,y=-32..-16,z=-15..-5
        on x=-18..26,y=-33..15,z=-7..46
        off x=-40..-22,y=-38..-28,z=23..41
        on x=-16..35,y=-41..10,z=-47..6
        off x=-32..-23,y=11..30,z=-14..3
        on x=-49..-5,y=-3..45,z=-29..18
        off x=18..30,y=-20..-8,z=-3..13
        on x=-41..9,y=-7..43,z=-33..15
        on x=-54112..-39298,y=-85059..-49293,z=-27449..7877
        on x=967..23432,y=45373..81175,z=27513..53682
        """,
        # TODO should generate these cases programmatically
        tests: [
          # |-cuboid-------------------------|  contained?  intersects?  description
          { {{-50, -50, -50}, { 50,  50,  50}}, true,       true,        "equal" },
          { {{-10, -10, -10}, { 10,  10,  10}}, true,       true,        "contained in middle" },

          # touching inside of one plane:
          { {{-10, -10, -10}, { 50,  10,  10}}, true,       true,        "contained just inside right" },
          { {{-50, -10, -10}, { 10,  10,  10}}, true,       true,        "contained just inside left" },
          { {{-10, -10, -10}, { 10,  50,  10}}, true,       true,        "contained just inside top" },
          { {{-10, -50, -10}, { 10,  10,  10}}, true,       true,        "contained just inside bottom" },
          { {{-10, -10, -10}, { 10,  10,  50}}, true,       true,        "contained just inside front" },
          { {{-10, -10, -50}, { 10,  10,  10}}, true,       true,        "contained just inside back" },
          # touching inside of two planes:
          { {{-10, -10, -10}, { 50,  50,  10}}, true,       true,        "contained just inside right-top" },
          { {{-50, -10, -10}, { 10,  50,  10}}, true,       true,        "contained just inside left-top" },
          { {{-10, -50, -10}, { 50,  10,  10}}, true,       true,        "contained just inside right-bottom" },
          { {{-50, -50, -10}, { 10,  10,  10}}, true,       true,        "contained just inside left-bottom" },
          { {{-10, -10, -10}, { 10,  50,  50}}, true,       true,        "contained just inside top-front" },
          { {{-10, -50, -10}, { 10,  10,  50}}, true,       true,        "contained just inside bottom-front" },
          { {{-10, -10, -50}, { 10,  50,  10}}, true,       true,        "contained just inside top-back" },
          { {{-10, -50, -50}, { 10,  10,  10}}, true,       true,        "contained just inside bottom-back" },
          { {{-10, -10, -10}, { 50,  10,  50}}, true,       true,        "contained just inside front-right" },
          { {{-10, -10, -50}, { 50,  10,  10}}, true,       true,        "contained just inside back-right" },
          { {{-50, -10, -10}, { 10,  10,  50}}, true,       true,        "contained just inside front-left" },
          { {{-50, -10, -50}, { 10,  10,  10}}, true,       true,        "contained just inside back-left" },
          # touching inside of three planes:
          { {{-10, -10, -10}, { 50,  50,  50}}, true,       true,        "contained just inside right-top-front" },
          { {{-10, -10, -50}, { 50,  50,  10}}, true,       true,        "contained just inside right-top-back" },
          { {{-50, -10, -10}, { 10,  50,  50}}, true,       true,        "contained just inside left-top-front" },
          { {{-50, -10, -50}, { 10,  50,  10}}, true,       true,        "contained just inside left-top-back" },
          { {{-10, -50, -10}, { 50,  10,  50}}, true,       true,        "contained just inside right-bottom-front" },
          { {{-10, -50, -50}, { 50,  10,  10}}, true,       true,        "contained just inside right-bottom-back" },
          { {{-50, -50, -10}, { 10,  10,  50}}, true,       true,        "contained just inside left-bottom-front" },
          { {{-50, -50, -50}, { 10,  10,  10}}, true,       true,        "contained just inside left-bottom-back" },

          # just peeking out of one plane:
          { {{-10, -10, -10}, { 51,  10,  10}}, false,      true,        "peeking just out of right" },
          { {{-51, -10, -10}, { 10,  10,  10}}, false,      true,        "peeking just out of left" },
          { {{-10, -10, -10}, { 10,  51,  10}}, false,      true,        "peeking just out of top" },
          { {{-10, -51, -10}, { 10,  10,  10}}, false,      true,        "peeking just out of bottom" },
          { {{-10, -10, -10}, { 10,  10,  51}}, false,      true,        "peeking just out of front" },
          { {{-10, -10, -51}, { 10,  10,  10}}, false,      true,        "peeking just out of back" },
          # just peeking out of two planes:
          { {{-10, -10, -10}, { 51,  51,  10}}, false,      true,        "peeking just out of right-top" },
          { {{-51, -10, -10}, { 10,  51,  10}}, false,      true,        "peeking just out of left-top" },
          { {{-10, -51, -10}, { 51,  10,  10}}, false,      true,        "peeking just out of right-bottom" },
          { {{-51, -51, -10}, { 10,  10,  10}}, false,      true,        "peeking just out of left-bottom" },
          { {{-10, -10, -10}, { 10,  51,  51}}, false,      true,        "peeking just out of top-front" },
          { {{-10, -51, -10}, { 10,  10,  51}}, false,      true,        "peeking just out of bottom-front" },
          { {{-10, -10, -51}, { 10,  51,  10}}, false,      true,        "peeking just out of top-back" },
          { {{-10, -51, -51}, { 10,  10,  10}}, false,      true,        "peeking just out of bottom-back" },
          { {{-10, -10, -10}, { 51,  10,  51}}, false,      true,        "peeking just out of front-right" },
          { {{-10, -10, -51}, { 51,  10,  10}}, false,      true,        "peeking just out of back-right" },
          { {{-51, -10, -10}, { 10,  10,  51}}, false,      true,        "peeking just out of front-left" },
          { {{-51, -10, -51}, { 10,  10,  10}}, false,      true,        "peeking just out of back-left" },
          # just peeking out of three planes:
          { {{-10, -10, -10}, { 51,  51,  51}}, false,      true,        "peeking just out of right-top-front" },
          { {{-10, -10, -51}, { 51,  51,  10}}, false,      true,        "peeking just out of right-top-back" },
          { {{-51, -10, -10}, { 10,  51,  51}}, false,      true,        "peeking just out of left-top-front" },
          { {{-51, -10, -51}, { 10,  51,  10}}, false,      true,        "peeking just out of left-top-back" },
          { {{-10, -51, -10}, { 51,  10,  51}}, false,      true,        "peeking just out of right-bottom-front" },
          { {{-10, -51, -51}, { 51,  10,  10}}, false,      true,        "peeking just out of right-bottom-back" },
          { {{-51, -51, -10}, { 10,  10,  51}}, false,      true,        "peeking just out of left-bottom-front" },
          { {{-51, -51, -51}, { 10,  10,  10}}, false,      true,        "peeking just out of left-bottom-back" },

          # barely overlapping one plane:
          { {{ 50, -10, -10}, { 70,  10,  10}}, false,      true,        "barely overlapping right" },
          { {{-70, -10, -10}, {-50,  10,  10}}, false,      true,        "barely overlapping left" },
          { {{-10,  50, -10}, { 10,  70,  10}}, false,      true,        "barely overlapping top" },
          { {{-10, -70, -10}, { 10, -50,  10}}, false,      true,        "barely overlapping bottom" },
          { {{-10, -10,  50}, { 10,  10,  70}}, false,      true,        "barely overlapping front" },
          { {{-10, -10, -70}, { 10,  10, -50}}, false,      true,        "barely overlapping back" },
          # barely overlapping two planes (a line):
          { {{ 50,  50, -10}, { 70,  70,  10}}, false,      true,        "barely overlapping right-top" },
          { {{-70,  50, -10}, {-50,  70,  10}}, false,      true,        "barely overlapping left-top" },
          { {{ 50, -70, -10}, { 70, -50,  10}}, false,      true,        "barely overlapping right-bottom" },
          { {{-70, -70, -10}, {-50, -50,  10}}, false,      true,        "barely overlapping left-bottom" },
          { {{-10,  50,  50}, { 10,  70,  70}}, false,      true,        "barely overlapping top-front" },
          { {{-10, -70,  50}, { 10, -50,  70}}, false,      true,        "barely overlapping bottom-front" },
          { {{-10,  50, -70}, { 10,  70, -50}}, false,      true,        "barely overlapping top-back" },
          { {{-10, -70, -70}, { 10, -50, -50}}, false,      true,        "barely overlapping bottom-back" },
          { {{ 50, -10,  50}, { 70,  10,  70}}, false,      true,        "barely overlapping front-right" },
          { {{ 50, -10, -70}, { 70,  10, -50}}, false,      true,        "barely overlapping back-right" },
          { {{-70, -10,  50}, {-50,  10,  70}}, false,      true,        "barely overlapping front-left" },
          { {{-70, -10, -70}, {-50,  10, -50}}, false,      true,        "barely overlapping back-left" },
          # barely overlapping three planes (a point):
          { {{ 50,  50,  50}, { 70,  70,  70}}, false,      true,        "barely overlapping right-top-front" },
          { {{-70,  50, -70}, {-50,  70, -50}}, false,      true,        "barely overlapping right-top-back" },
          { {{ 50,  50,  50}, { 70,  70,  70}}, false,      true,        "barely overlapping left-top-front" },
          { {{-70,  50, -70}, {-50,  70, -50}}, false,      true,        "barely overlapping left-top-back" },
          { {{ 50, -70,  50}, { 70, -50,  70}}, false,      true,        "barely overlapping right-bottom-front" },
          { {{-70, -70, -70}, {-50, -50, -50}}, false,      true,        "barely overlapping right-bottom-back" },
          { {{ 50, -70,  50}, { 70, -50,  70}}, false,      true,        "barely overlapping left-bottom-front" },
          { {{-70, -70, -70}, {-50, -50, -50}}, false,      true,        "barely overlapping left-bottom-back" },

          # just outside one plane:
          { {{ 51, -10, -10}, { 70,  10,  10}}, false,      false,       "just outside right" },
          { {{-70, -10, -10}, {-51,  10,  10}}, false,      false,       "just outside left" },
          { {{-10,  51, -10}, { 10,  70,  10}}, false,      false,       "just outside top" },
          { {{-10, -70, -10}, { 10, -51,  10}}, false,      false,       "just outside bottom" },
          { {{-10, -10,  51}, { 10,  10,  70}}, false,      false,       "just outside front" },
          { {{-10, -10, -70}, { 10,  10, -51}}, false,      false,       "just outside back" },
          # just outside two planes (a line):
          { {{ 51,  51, -10}, { 70,  70,  10}}, false,      false,       "just outside right-top" },
          { {{-70,  51, -10}, {-51,  70,  10}}, false,      false,       "just outside left-top" },
          { {{ 51, -70, -10}, { 70, -51,  10}}, false,      false,       "just outside right-bottom" },
          { {{-70, -70, -10}, {-51, -51,  10}}, false,      false,       "just outside left-bottom" },
          { {{-10,  51,  51}, { 10,  70,  70}}, false,      false,       "just outside top-front" },
          { {{-10, -70,  51}, { 10, -51,  70}}, false,      false,       "just outside bottom-front" },
          { {{-10,  51, -70}, { 10,  70, -51}}, false,      false,       "just outside top-back" },
          { {{-10, -70, -70}, { 10, -51, -51}}, false,      false,       "just outside bottom-back" },
          { {{ 51, -10,  51}, { 70,  10,  70}}, false,      false,       "just outside front-right" },
          { {{ 51, -10, -70}, { 70,  10, -51}}, false,      false,       "just outside back-right" },
          { {{-70, -10,  51}, {-51,  10,  70}}, false,      false,       "just outside front-left" },
          { {{-70, -10, -70}, {-51,  10, -51}}, false,      false,       "just outside back-left" },
          # just outside three planes (a point):
          { {{ 51,  51,  51}, { 70,  70,  70}}, false,      false,       "just outside right-top-front" },
          { {{-70,  51, -70}, {-51,  70, -51}}, false,      false,       "just outside right-top-back" },
          { {{ 51,  51,  51}, { 70,  70,  70}}, false,      false,       "just outside left-top-front" },
          { {{-70,  51, -70}, {-51,  70, -51}}, false,      false,       "just outside left-top-back" },
          { {{ 51, -70,  51}, { 70, -51,  70}}, false,      false,       "just outside right-bottom-front" },
          { {{-70, -70, -70}, {-51, -51, -51}}, false,      false,       "just outside right-bottom-back" },
          { {{ 51, -70,  51}, { 70, -51,  70}}, false,      false,       "just outside left-bottom-front" },
          { {{-70, -70, -70}, {-51, -51, -51}}, false,      false,       "just outside left-bottom-back" },
        ],
        shaving_tests: [
          # NOTE test "shaving (fully contained)" (below)
          #      - tests the "engulfed-by" case
          # NOTE test "shaving (no intersection)" (below)
          #      - tests cuboids that don't intersect
          # overlapping one plane:
          { {{-62, -43, -47}, { 42,  23,  47}}, "overlapping left",
            []
          },
          { {{-42, -23, -47}, { 42,  63,  47}}, "overlapping top",
            []
          },
          { {{-42, -43, -67}, { 42,  43,  27}}, "overlapping back",
            []
          },
          # overlapping two planes:
          { {{-22, -63, -47}, { 62,  23,  47}}, "overlapping right-bottom",
            []
          },
          { {{-42, -63, -27}, { 42,  23,  67}}, "overlapping bottom-front",
            []
          },
          { {{-22, -43, -27}, { 62,  43,  67}}, "overlapping front-right",
            []
          },
          { {{-62, -43, -67}, { 22,  43,  27}}, "overlapping back-left",
            []
          },
          # overlapping three planes:
          { {{-22, -23, -27}, { 62,  63,  67}}, "overlapping right-top-front",
            [
              {{-22, -23,  51}, { 50,  50,  67}},  # front
              {{-22,  51, -27}, { 50,  63,  67}},  # top
              {{ 51, -23, -27}, { 62,  63,  67}},  # right
            ]
          },
          { {{-62, -23, -67}, { 22,  63,  27}}, "overlapping left-top-back",
            [
              {{-50, -23, -67}, { 22,  50, -51}},  # back
              {{-50,  51, -67}, { 22,  63,  27}},  # top
              {{-62, -23, -67}, {-51,  63,  27}},  # left
            ]
          },
          { {{-22, -63, -27}, { 62,  23,  67}}, "overlapping right-bottom-front",
            [
              {{-22, -50,  51}, { 50,  23,  67}},  # front
              {{-22, -63, -27}, { 50, -51,  67}},  # bottom
              {{ 51, -63, -27}, { 62,  23,  67}},  # right
            ]
          },
          { {{-62, -63, -67}, { 22,  23,  27}}, "overlapping left-bottom-back",
            [
              {{-50, -50, -67}, { 22,  23, -51}},  # back
              {{-50, -63, -67}, { 22, -51,  27}},  # bottom
              {{-62, -63, -67}, {-51,  23,  27}},  # left
            ]
          },
          # engulfing:
          { {{-62, -63, -67}, { 62,  63,  67}}, "overlapping all (engulfing)",
            [
              {{-50, -50, -67}, { 50,  50, -51}},  # back
              {{-50, -50,  51}, { 50,  50,  67}},  # front
              {{-50, -63, -67}, { 50, -51,  67}},  # bottom
              {{-50,  51, -67}, { 50,  63,  67}},  # top
              {{-62, -63, -67}, {-51,  63,  67}},  # left
              {{ 51, -63, -67}, { 62,  63,  67}},  # right
            ]
          },
        ],
        cuboids_to_sum: [
          {{10, 10, 10}, {12, 12, 12}},  # 3x3x3 = 27
          {{-5, -9, -7}, {-5, -5, -4}},  # 1x5x4 = 20
          {{ 0,  0,  0}, { 0,  7,  0}},  # 1x8x1 = 8
          {{ 3,  3,  3}, { 3,  3,  3}},  # 1x1x1 = 1
        ],
        exp_cuboid_sum: 27 + 20 + 8 + 1,
      ]
    end

    test "detect valid and invalid cuboids" do
      [
        {{ 0,  0,  0}, { 0,  0,  0}},  # point
        {{-1, -1, -1}, {-1,  3, -1}},  # line (y)
        {{-5, -1,  2}, {-2, -1,  5}},  # plane (x, z)
        {{ 2,  2,  2}, { 6,  6,  6}},  # cube
        {{-7,  2, -4}, { 6,  4, -2}},  # cube
      ]
      |> Enum.each(fn cuboid -> Cuboid.assert_valid(cuboid) == true end)
      [
        {{-1, -1, -1}, {-2, -1, -1}},  # bad line x
        {{-1,  3, -1}, {-1,  2, -1}},  # bad line y
        {{-1, -1, 10}, {-1, -1, -1}},  # bad line z
        {{ 2,  2,  2}, { 1,  6,  6}},  # bad cube x
        {{ 2,  6,  2}, { 6,  2,  6}},  # bad cube y
        {{ 2,  2, -2}, { 6,  6, -3}},  # bad cube z
      ]
      |> Enum.each(fn cuboid ->
        assert_raise ArgumentError, fn -> Cuboid.assert_valid(cuboid) end
      end)
    end

    test "detect valid and invalid cuboids (puzzle input)" do
      File.read!("input/input.txt")
      |> Parser.parse()
      |> Enum.map(&(elem(&1, 1)))
      |> Enum.each(fn cuboid -> Cuboid.assert_valid(cuboid) == true end)
    end

    test "fully contained or fully outside (part 1 larger example)", fixture do
      range_50 = {{-50, -50, -50}, {50, 50, 50}}
      Parser.parse(fixture.larger_input)
      |> Enum.each(fn {_on_off, cuboid} ->
        assert Cuboid.contains?(range_50, cuboid) or !Cuboid.intersects?(range_50, cuboid)
      end)
    end

    test "fully contained or fully outside (puzzle input)" do
      range_50 = {{-50, -50, -50}, {50, 50, 50}}
      File.read!("input/input.txt")
      |> Parser.parse()
      |> Enum.each(fn {_on_off, cuboid} ->
        assert Cuboid.contains?(range_50, cuboid) or !Cuboid.intersects?(range_50, cuboid)
      end)
    end

    test "containment and intersection tests", fixture do
      range_50 = {{-50, -50, -50}, {50, 50, 50}}
      fixture.tests
      |> Enum.each(fn {cuboid, contained, intersects, _description} ->
        assert Cuboid.contains?(range_50, cuboid) == contained
        assert Cuboid.intersects?(range_50, cuboid) == intersects
      end)
    end

    test "shaving (fully contained)", fixture do
      range_50 = {{-50, -50, -50}, {50, 50, 50}}
      fixture.tests
      |> Enum.each(fn {cuboid, contained, _intersects, _description} ->
        if contained do
          assert Cuboid.shave(range_50, cuboid) == []
        end
      end)
    end

    test "shaving (no intersection)", fixture do
      range_50 = {{-50, -50, -50}, {50, 50, 50}}
      fixture.tests
      |> Enum.each(fn {cuboid, _contained, intersects, _description} ->
        if !intersects do
          assert Cuboid.shave(range_50, cuboid) == []
        end
      end)
    end

    test "shaving (partial intersection)", fixture do
      range_50 = {{-50, -50, -50}, {50, 50, 50}}
      fixture.shaving_tests
      |> Enum.each(fn {cuboid, _description, exp_shaved_cuboids} ->
        if exp_shaved_cuboids != [] do  # TODO finish the rest of the tests
          assert Cuboid.shave(range_50, cuboid) == exp_shaved_cuboids
        end
      end)
    end

    test "cuboid counter gets expected sum", fixture do
      assert Cuboid.count_on(fixture.cuboids_to_sum) == fixture.exp_cuboid_sum
    end
  end
end
