defmodule RobotTest do
  use ExUnit.Case
  doctest Robot, import: true

  describe "puzzle example" do
    setup do
      [
        robots: [
          {{4, 0}, {-3, 3}},
          {{3, 6}, {-3, -1}},
          {{3, 10}, {2, -1}},
          {{0, 2}, {-1, 2}},
          {{0, 0}, {3, 1}},
          {{0, 3}, {-2, -2}},
          {{6, 7}, {-3, -1}},
          {{0, 3}, {-2, -1}},
          {{3, 9}, {3, 2}},
          {{3, 7}, {2, -1}},
          {{4, 2}, {-3, 2}},
          {{5, 9}, {-3, -3}},
        ],
        small_dim: {7, 11},
        exp_quadrant_count: [1, 3, 4, 1],
        exp_safety_factor: 12,
      ]
    end

    test "find safety factor after 100 seconds", fixture do
      locations =
        fixture.robots
        |> Enum.map(&(Robot.location_after(&1, fixture.small_dim, 100)))
      act_quadrant_count =
        locations
        |> Robot.quadrant_count(fixture.small_dim)
      assert act_quadrant_count == fixture.exp_quadrant_count
      act_safety_factor =
        locations
        |> Robot.safety_factor(fixture.small_dim)
      assert act_safety_factor == fixture.exp_safety_factor
    end

    # TODO turn this into property-based test
    #test "find steps during 100 seconds", fixture do
    #  robot = fixture.robots
    #          |> Enum.at(0)
    #  exp_steps =
    #    1..100
    #    |> Enum.map(&(Robot.location_after_by_adding(robot, fixture.small_dim, &1)))
    #  act_steps =
    #    1..100
    #    |> Enum.map(&(Robot.location_after(robot, fixture.small_dim, &1)))
    #  assert act_steps == exp_steps
    #end

    #test "create PNMs and GIF", fixture do
    #  input_robots =
    #    File.read!("private/input.txt")
    #    |> Robot.Parser.parse_input_string
    #  input_dim = {103, 101}
    #  0..1_200
    #  |> Enum.reduce(input_robots, fn s, robots ->
    #    Robot.create_pnm(robots, s, input_dim)
    #    robots
    #    |> Enum.map(&(Robot.location_after(&1, input_dim, 1)))
    #    |> Enum.zip(robots)
    #    |> Enum.map(fn {{x, y}, {_, {dx, dy}}} ->
    #      {{x, y}, {dx, dy}}
    #    end)
    #  end)
    #end
  end
end
