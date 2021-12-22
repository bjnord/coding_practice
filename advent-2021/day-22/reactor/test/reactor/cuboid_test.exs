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
  end
end
