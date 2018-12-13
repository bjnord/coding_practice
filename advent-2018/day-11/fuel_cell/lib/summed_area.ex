defmodule SummedArea do
  @moduledoc """
  Method for quickly finding the sum of all cells in an arbitrary
  rectangle.

  This implements the impressive
  [summed-area table](https://en.wikipedia.org/wiki/Summed-area_table)
  algorithm, which finds the sum of all cells in an arbitrary rectangle,
  by adding/subtracting just 4 values from the S.A.T. — _i.e._ in
  constant time.

  Thanks to the folks at the Reddit day 11 solution megathread for the
  pointer, as well as elegant implementations
  [like this one](https://www.reddit.com/r/adventofcode/comments/a53r6i/2018_day_11_solutions/ebjogd7/).
  """

  @doc """
  Create a summed-area table from a corresponding table of values.
  
  Coordinates of both tables are an `{x, y}` tuple (1-relative); the
  tuple is the key for the Map that holds the table. Each cell in the
  resulting S.A.T. is calculated as:

  `SAT{x, y} = cell{x, y} + SAT{x, y-1} + SAT{x-1, y} - SAT{x-1, y-1}`

  The middle two terms (rectangles) overlap (_i.e._ they double-count),
  so the last term subtracts out the overlap.

  ## Parameters

  - source: Table of source cell values (Map w/key = {x, y} tuple)
  - {x_range, y_range}: Dimensions of input and output tables

  ## Returns

  The summed-area table (Map w/key = {x, y} tuple)

  ## Example

      iex> source = %{
      ...>   {1, 1} => 4, {1, 2} => 3, {1, 3} => 8,
      ...>   {2, 1} => 9, {2, 2} => 5, {2, 3} => 1,
      ...>   {3, 1} => 2, {3, 2} => 6, {3, 3} => 7,
      ...> }
      iex> SummedArea.new(source, {1..3, 1..3})
      %{
        {1, 1} => 4,
        {1, 2} => 7,
        {1, 3} => 15,
        {2, 1} => 13,
        {2, 2} => 21,
        {2, 3} => 30,
        {3, 1} => 15,
        {3, 2} => 29,
        {3, 3} => 45,
      }

  """
  def new(source, {x_range, y_range}) do
    Enum.reduce(x_range, %{}, fn (x, acc) ->
      Enum.reduce(y_range, acc, fn (y, acc) ->
        Map.put(acc, {x, y}, sat_value(source, acc, {x, y}))
      end)
    end)
  end

  defp sat_value(source, _sat, {x, y}) when x==1 and y==1,
    do: source[{x, y}]

  defp sat_value(source, _sat, {x, y}) when x==1,
    do: Enum.reduce(1..y, 0, fn (j, acc) -> acc + source[{x, j}] end)

  defp sat_value(source, _sat, {x, y}) when y==1,
    do: Enum.reduce(1..x, 0, fn (i, acc) -> acc + source[{i, y}] end)

  defp sat_value(source, sat, {x, y}),
    do: source[{x, y}] + sat[{x, y-1}] + sat[{x-1, y}] - sat[{x-1, y-1}]

  @doc """
  Calculate the summed area of a rectangle (in constant time).

  For an NxM rectangle where N = x..x1 and M = y..y1,

  `SAT{NxM} = SAT{x1, y1} - SAT{x1, y-1} - SAT{x-1, y1} + SAT{x-1, y-1}`

  The middle two terms (rectangles) overlap (_i.e._ they double-count),
  so the last term compensates.

  ## Parameters

  - sat: Summed-area table (Map w/key = {x, y} tuple)
  - {x, y}: Upper-left coordinate of rectangle to calculate
  - {xs, ys}: Size of rectangle to calculate

  ## Returns

  The total summed area (integer)

  ## Examples

      iex> sat = %{
      ...>   {1, 1} =>  4, {1, 2} =>  7, {1, 3} => 15,
      ...>   {2, 1} => 13, {2, 2} => 21, {2, 3} => 30,
      ...>   {3, 1} => 15, {3, 2} => 29, {3, 3} => 45,
      ...> }
      iex> SummedArea.area(sat, {1, 1}, {2, 2})
      21
      iex> SummedArea.area(sat, {1, 1}, {3, 3})
      45
      iex> SummedArea.area(sat, {2, 1}, {2, 2})
      22
      iex> SummedArea.area(sat, {1, 2}, {2, 2})
      17
      iex> SummedArea.area(sat, {2, 2}, {2, 2})
      19
      iex> SummedArea.area(sat, {3, 2}, {1, 2})
      13
      iex> SummedArea.area(sat, {2, 3}, {2, 1})
      8

  """
  def area(sat, {x, y}, {xs, ys}) do
    x1 = x + xs - 1
    y1 = y + ys - 1
    sat_area(sat, {x, y}, {x1, y1})
  end

  defp sat_area(sat, {x, y}, {x1, y1}) when x==1 and y==1,
    do: sat[{x1, y1}]

  defp sat_area(sat, {x, y}, {x1, y1}) when x==1,
    do: sat[{x1, y1}] - sat[{x1, y-1}]

  defp sat_area(sat, {x, y}, {x1, y1}) when y==1,
    do: sat[{x1, y1}] - sat[{x-1, y1}]

  defp sat_area(sat, {x, y}, {x1, y1}),
    do: sat[{x1, y1}] - sat[{x1, y-1}] - sat[{x-1, y1}] + sat[{x-1, y-1}]
end
