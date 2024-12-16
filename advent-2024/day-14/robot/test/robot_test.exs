defmodule RobotTest do
  use ExUnit.Case
  doctest Robot, import: true

  require Logger

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
        exp_p2_min_seconds: 6644,
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

    #test "find seconds to minimum safety factor (on my puzzle input)", fixture do
    #  input_robots =
    #    File.read!("private/input.txt")
    #    |> Robot.Parser.parse_input_string
    #  input_dim = {103, 101}
    #  n_seconds = 10_000
    #  {min_seconds, min_safety_factor} =
    #    Robot.safety_factors(input_robots, input_dim, n_seconds)
    #    |> Enum.min_by(fn {_s, sf} -> sf end)
    #  n0 = Integer.to_string(min_seconds)
    #       |> String.pad_leading(8, "0")
    #  filename = "images/sec#{n0}.pnm"
    #  Logger.debug("n_seconds=#{n_seconds} min_seconds=#{min_seconds} min_safety_factor=#{min_safety_factor} image_f=#{filename}")
    #  assert min_seconds == fixture.exp_p2_min_seconds
    #end

    # TODO turn this into property-based test
    #test "find steps during 100 seconds", fixture do
    #  robot = fixture.robots
    #          |> Enum.random()
    #          #|> IO.inspect(label: "randomly-chosen robot")
    #  exp_steps =
    #    1..100
    #    |> Enum.map(&(Robot.location_after_by_adding(robot, fixture.small_dim, &1)))
    #  act_steps =
    #    1..100
    #    |> Enum.map(&(Robot.location_after(robot, fixture.small_dim, &1)))
    #  assert act_steps == exp_steps
    #end

    #test "create PNMs and GIF" do
    #  input_robots =
    #    File.read!("private/input.txt")
    #    |> Robot.Parser.parse_input_string
    #  input_dim = {103, 101}
    #  n_seconds = 10_000
    #  0..n_seconds
    #  |> Enum.reduce(input_robots, fn s, robots ->
    #    Robot.create_pnm(robots, s, input_dim)
    #    robots
    #    |> Enum.map(&(Robot.location_after(&1, input_dim, 1)))
    #    |> Enum.zip(robots)
    #    |> Enum.map(fn {{y, x}, {_, {dy, dx}}} ->
    #      {{y, x}, {dy, dx}}
    #    end)
    #  end)
    #end
  end
end
