defmodule Reservoir.Flow do
  @doc ~S"""
  Parse the clay veins found in the puzzle input.

  ## Returns

  A grid map describing what's underground.

  ## Example

  # ..+..
  # #....
  # #.###
  # #....

      iex> earth = Reservoir.Flow.parse_clay_input([
      ...>   "x=498, y=1..3\n",
      ...>   "y=2, x=500..502\n",
      ...> ])
      iex> earth
      %{
        {1, 497} => :sand, {1, 498} => :clay, {1, 499} => :sand, {1, 500} => :sand,
                           {1, 501} => :sand, {1, 502} => :sand, {1, 503} => :sand,
        {2, 497} => :sand, {2, 498} => :clay, {2, 499} => :sand, {2, 500} => :clay,
                           {2, 501} => :clay, {2, 502} => :clay, {2, 503} => :sand,
        {3, 497} => :sand, {3, 498} => :clay, {3, 499} => :sand, {3, 500} => :sand,
                           {3, 501} => :sand, {3, 502} => :sand, {3, 503} => :sand,
      }
  """
  @spec parse_clay_input([String.t()]) :: [tuple()]
  def parse_clay_input(lines) when is_list(lines) do
    earth =
      lines
      |> Enum.reduce(MapSet.new(), fn (line, clay) ->
        parse_line(line)
        |> Enum.reduce(clay, fn (pos, clay) -> MapSet.put(clay, pos) end)
      end)
      |> Enum.reduce(%{}, fn (pos, earth) ->
        Map.put(earth, pos, :clay)
      end)
    {min_y, min_x, max_y, max_x} = min_max_of_earth(earth)
    sand_squares =
      for y <- min_y..max_y, x <- (min_x-1)..(max_x+1), !earth[{y, x}], do: {y, x}
    sand_squares
    |> Enum.reduce(earth, fn (pos, earth) -> Map.put(earth, pos, :sand) end)
  end

  defp parse_line(line) when is_binary(line) do
    vert = Regex.run(~r/x=(\d+), y=(\d+)..(\d+)/, line)
    horiz = Regex.run(~r/y=(\d+), x=(\d+)..(\d+)/, line)
    cond do
      vert ->
        [_, x, min_y, max_y] = vert
        String.to_integer(min_y)..String.to_integer(max_y)
        |> Enum.map(&({&1, String.to_integer(x)}))
      horiz ->
        [_, y, min_x, max_x] = horiz
        String.to_integer(min_x)..String.to_integer(max_x)
        |> Enum.map(&({String.to_integer(y), &1}))
    end
  end

  defp square_type(square) do
    case square do
      "." -> :sand
      "#" -> :clay
      "|" -> :flow
      "~" -> :water
    end
  end

  def dump_earth(earth) do
    IO.write("\n")
    {min_y, min_x, max_y, max_x} = min_max_of_earth(earth)
    dump_spring_line(min_x..max_x)
    min_y..max_y
    |> Enum.map(fn (y) -> dump_earth_line(earth, y, min_x..max_x) end)
  end

  defp min_max_of_earth(earth) do
    {min_y, max_y} =
      Enum.map(earth, &(elem(elem(&1, 0), 0)))
      |> Enum.min_max()
    {min_x, max_x} =
      Enum.map(earth, &(elem(elem(&1, 0), 1)))
      |> Enum.min_max()
    {min_y, min_x, max_y, max_x}
  end

  defp dump_spring_line(x_range) do
    x_range
    |> Enum.map(&(emit_spring_square(&1)))
    IO.write("\n")
  end

  defp emit_spring_square(x) do
    if x == 500 do
      '+'  # :spring
    else
      '.'  # :sand
    end
    |> IO.write
  end

  defp dump_earth_line(earth, y, x_range) do
    x_range
    |> Enum.map(&(emit_earth_square(earth, {y, &1})))
    IO.write("\n")
  end

  defp emit_earth_square(earth, pos) do
    case earth[pos] do
      :sand -> '.'
      :clay -> '#'
      :flow -> '|'
      :water -> '~'
    end
    |> IO.write
  end
end
