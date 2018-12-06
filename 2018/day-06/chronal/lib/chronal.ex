defmodule Chronal do
  @moduledoc """
  Documentation for Chronal.
  """

  defp abort(message, excode) do
    IO.puts(:stderr, message)
    System.halt(excode)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 1 answer is: ...
  """
  def part1(argv) do
    points = argv
             |> input_file
             |> File.stream!
             |> Enum.map(&Chronal.input_point/1)
    canvas = canvas_dimensions(points)
             |> IO.inspect(label: "canvas dimensions")
    finite_area_points(points, canvas)
    |> IO.inspect(label: "finite-area points")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(argv) do
    argv
    |> input_file
  end

  @doc """
  Get name of input file from command-line arguments.

  ## Parameters

  - argv: Command-line arguments

  ## Returns

  Input filename (or aborts if argv invalid)
  """
  def input_file(argv) do
    case argv do
      [filename] -> filename
      _          -> abort('Usage: chronal filename', 64)
    end
  end

  @doc """
  Parse input point from string.

  ## Parameters

  - string of the form "23, 45\n"

  ## Returns

  Point coordinates as {x, y} tuple
  """
  def input_point(str) do
    r = Regex.named_captures(~r/(?<x>\d+),\s+(?<y>\d+)/, str)
    {String.to_integer(r["x"]), String.to_integer(r["y"])}
  end

  @doc """
  Compute the Manhattan distance between two points.

  "Take the sum of the absolute values of the differences of the coordinates.
  For example, if x=(a,b) and y=(c,d), the Manhattan distance between x and y is |a−c|+|b−d|."
  <https://math.stackexchange.com/a/139604>

  ## Parameters

  - {x1, y1}: coordinates of first point (integers)
  - {x2, y2}: coordinates of second point (integers)

  ## Returns

  Manhattan distance between the two points (integer)

  """
  def manhattan({x1, y1}, {x2, y2}) do
    Kernel.abs(x1 - x2) + Kernel.abs(y1 - y2)
  end

  @doc """
  Find the closest point(s) to the given coordinates.

  ## Parameters

  - {xc, yc}: coordinates to measure from (integers)
  - points: list of points ({x, y} integer tuples)

  ## Returns

  List of points ({x, y} integer tuples) that are closest to provided coordinates.
  (Returned points will be in the same order as they were in the input list.)

  """
  def closest_points({xc, yc}, points) do
    shortest = points
               |> Enum.map(fn (p) -> manhattan(p, {xc, yc}) end)
               |> Enum.min
    points
    |> Enum.filter(fn (p) -> manhattan(p, {xc, yc}) == shortest end)
  end

  @doc """
  Find the point(s) with finite areas within the canvas.

  ## Parameters

  - points: list of points ({x, y} integer tuples)
  - {min_x, min_y, max_x, max_y}: dimensions of canvas (integers)

  ## Returns

  List of points ({x, y} integer tuples) that have finite areas.
  (Returned points will be in the same order as they were in the input list.)

  """
  def finite_area_points(points, {min_x, min_y, max_x, max_y}) do
    # measure from canvas edges; any edge location that has a single closest
    # point means that point will have an infinite area
    infinite = MapSet.new()
    infinite = Enum.reduce(min_x..max_x, infinite, fn (x, acc) ->
      closest_points({x, min_y}, points)
      |> pass_single_elem
      |> Enum.reduce(acc, fn (p, acc2) -> MapSet.put(acc2, p) end)
    end)
    infinite = Enum.reduce(min_x..max_x, infinite, fn (x, acc) ->
      closest_points({x, max_y}, points)
      |> pass_single_elem
      |> Enum.reduce(acc, fn (p, acc2) -> MapSet.put(acc2, p) end)
    end)
    infinite = Enum.reduce(min_y..max_y, infinite, fn (y, acc) ->
      closest_points({min_x, y}, points)
      |> pass_single_elem
      |> Enum.reduce(acc, fn (p, acc2) -> MapSet.put(acc2, p) end)
    end)
    infinite = Enum.reduce(min_y..max_y, infinite, fn (y, acc) ->
      closest_points({max_x, y}, points)
      |> pass_single_elem
      |> Enum.reduce(acc, fn (p, acc2) -> MapSet.put(acc2, p) end)
    end)
    # now the list of finite points is simply all the non-infinite ones
    points
    |> Enum.reject(fn (p) -> MapSet.member?(infinite, p) end)
  end

  # if list has more than one element, empty it
  defp pass_single_elem(list) do
    [_head | tail] = list
    if tail == [], do: list, else: []
  end

  @doc """
  Compute the bounding box of a set of points.

  ## Parameters

  - List of {x, y} points (integers)

  ## Returns

  Bounding coordinates as {min_x, min_y, max_x, max_y} (integers)

  """
  def bounds(points) do
    min_x = Enum.min_by(points, fn { x, _y} -> x end) |> Kernel.elem(0)
    min_y = Enum.min_by(points, fn {_x,  y} -> y end) |> Kernel.elem(1)
    max_x = Enum.max_by(points, fn { x, _y} -> x end) |> Kernel.elem(0)
    max_y = Enum.max_by(points, fn {_x,  y} -> y end) |> Kernel.elem(1)
    {min_x, min_y, max_x, max_y}
  end

  # the canvas is infinite, but we compute a sufficiently large margin
  # around the bounding box of the input points
  defp canvas_dimensions(points) do
    {min_x, min_y, max_x, max_y} = bounds(points)
    {
      min_x - (max_x - min_x + 2),
      min_y - (max_y - min_y + 2),
      max_x + (max_x - min_x + 2),
      max_y + (max_y - min_y + 2)
    }
  end
end
