defmodule RobotTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 100]
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

  ###
  # Property-Based Tests
  #
  # with help from Fred Hebert's book,
  # [Property-Based Testing with PropEr, Erlang, and Elixir](https://pragprog.com/titles/fhproper)
  #
  # Published: Jan 2019, Pragmatic Programmers
  # ISBN: 9781680506211

  ###
  # Properties

  property "robot location is correct after N seconds of movement" do
    forall {dim, robot, secs} <- gen_robot_scenario() do
      Robot.location_after(robot, dim, secs) == location_after_by_addition(robot, dim, secs)
    end
  end

  ###
  # Helpers
  #
  # (this will be our alternate "obviously correct" implementation

  def location_after_by_addition(robot, dim, secs) do
    #{dim, robot, secs}
    #|> IO.inspect(label: "location_after_by_addition {dim, robot, secs}")
    1..secs
    |> Enum.reduce(robot, fn _, robot ->
      step(robot, dim)
    end)
    |> elem(0)
  end

  def step({{y, x}, {dy, dx}}, {dim_y, dim_x}) do
    y = y + dy
    y =
      cond do
        y >= dim_y ->
          y - dim_y
        y < 0 ->
          y + dim_y
        true ->
          y
      end
    x = x + dx
    x =
      cond do
        x >= dim_x ->
          x - dim_x
        x < 0 ->
          x + dim_x
        true ->
          x
      end
    {{y, x}, {dy, dx}}
  end

  ###
  # Generators
  #
  # the puzzle input data looks like this:
  #
  # position X = 0..100, position Y = 0..102 (so taller than wide)
  #   (example dim = 11 x 7, so is wider than tall)
  # velocity X and Y both = -99..99 including 0
  #   (could probably use `dim - 2` safely _i.e._ -101..101)
  # N robots = 500 (so roughly `dim_x * 5`)
  #   (example N robots = 12, so roughly `dim_x * 2`)
  #
  # key requirements:
  # - unequal odd X and Y dimensions (slightly rectangular)
  # - robot position within dimensions
  # - robot abs(velocity) less than dimensions

  def gen_robot_scenario() do
    let dim <- gen_dimensions(9, 101) do
      {
        dim,
        gen_robot(dim),
        gen_seconds(),
      }
    end
  end

  def gen_odd_dimension(lo \\ 2, hi \\ :inf) do
    let n <- range(div(lo, 2), div(hi, 2)) do
      n * 2 + 1
    end
  end

  def gen_adjustment() do
    oneof([{-2, 0}, {0, 2}, {2, 0}, {-2, 0}])
  end

  def gen_dimensions(lo \\ 2, hi \\ :inf) do
    let {dim, {dy, dx}} <- {gen_odd_dimension(lo, hi), gen_adjustment()} do
      {dim + dy, dim + dx}
    end
  end

  # example & puzzle input both use all rows and columns
  def gen_robot_pos(g_dim) do
    let {dim_y, dim_x} <- g_dim do
      {range(0, dim_y - 1), range(0, dim_x - 1)}
    end
  end

  # example & puzzle input both have `abs(vel) < dim` (in both dimensions)
  def gen_robot_vel(g_dim) do
    let {dim_y, dim_x} <- g_dim do
      {range(-dim_y + 2, dim_y - 2), range(-dim_x + 2, dim_x - 2)}
    end
  end

  def gen_robot(g_dim) do
    {gen_robot_pos(g_dim), gen_robot_vel(g_dim)}
  end

  # example & puzzle input use 100 seconds
  def gen_seconds(), do: range(30, 130)
end
