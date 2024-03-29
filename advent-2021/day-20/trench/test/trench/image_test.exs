defmodule Trench.ImageTest do
  use ExUnit.Case
  doctest Trench.Image

  alias Trench.Image, as: Image
  alias Trench.Parser, as: Parser

  describe "puzzle example" do
    setup do
      [
        algor: "..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#",
        radius: 2,
        pixmap: %{
          {-2, -2} => 1, {-1, -2} => 0, { 0, -2} => 0, { 1, -2} => 1, { 2, -2} => 0,
          {-2, -1} => 1, {-1, -1} => 0, { 0, -1} => 0, { 1, -1} => 0, { 2, -1} => 0,
          {-2,  0} => 1, {-1,  0} => 1, { 0,  0} => 0, { 1,  0} => 0, { 2,  0} => 1,
          {-2,  1} => 0, {-1,  1} => 0, { 0,  1} => 1, { 1,  1} => 0, { 2,  1} => 0,
          {-2,  2} => 0, {-1,  2} => 0, { 0,  2} => 1, { 1,  2} => 1, { 2,  2} => 1,
        },
        exp_step_1_new_pixels: [0, 1, 0, 1, 1, 0, 0, 0, 1],
        exp_step_1_radius: 6,
        exp_step_1: """
        .............
        .............
        .............
        ....##.##....
        ...#..#.#....
        ...##.#..#...
        ...####..#...
        ....#..##....
        .....##..#...
        ......#.#....
        .............
        .............
        .............
        """,
        exp_step_2_radius: 7,
        exp_step_2_lit: 35,
        exp_step_2: """
        ...............
        ...............
        ...............
        ..........#....
        ....#..#.#.....
        ...#.#...###...
        ...#...##.#....
        ...#.....#.#...
        ....#.#####....
        .....#.#####...
        ......##.##....
        .......###.....
        ...............
        ...............
        ...............
        """,
        exp_step_50_lit: 3351,
      ]
    end

    test "algorithm produces expected new pixels", fixture do
      algor = Parser.parse_algor(fixture.algor)
      image = Image.new({fixture.radius, fixture.pixmap})
      act_new_pixels =
        [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {0, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]
        |> Enum.reduce({image, []}, fn (pos, {enh_image, pixels}) ->
          {px, enh_image} = Image.set_new_pixel_at(enh_image, image, algor, pos)
          {enh_image, [px | pixels]}
        end)
        |> elem(1)
        |> Enum.reverse()
      assert act_new_pixels == fixture.exp_step_1_new_pixels
    end

    test "image gets expected algorithm result (two steps)", fixture do
      algor = Parser.parse_algor(fixture.algor)
      ###
      # Step 1
      image_step_1 =
        Image.new({fixture.radius, fixture.pixmap})
        |> Image.apply(algor)
      assert Image.pixel_at(image_step_1, {-81518, 1202}) == 0  # test infinite canvas
      assert Image.radius(image_step_1) == fixture.exp_step_1_radius
      assert Image.render(image_step_1) == fixture.exp_step_1
      ###
      # Step 2
      image_step_2 = Image.apply(image_step_1, algor)
      assert Image.radius(image_step_2) == fixture.exp_step_2_radius
      assert Image.render(image_step_2) == fixture.exp_step_2
      assert Image.lit_count(image_step_2) == fixture.exp_step_2_lit
    end

    test "image gets expected algorithm result (50 steps)", fixture do
      algor = Parser.parse_algor(fixture.algor)
      image = Image.new({fixture.radius, fixture.pixmap})
      enh_image =
        1..50
        |> Enum.reduce(image, fn (_n, enh_image) ->
          Image.apply(enh_image, algor)
        end)
      assert Image.lit_count(enh_image) == fixture.exp_step_50_lit
    end
  end
end
