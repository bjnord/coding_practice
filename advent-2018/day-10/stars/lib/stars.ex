defmodule Stars do
  @moduledoc """
  Documentation for Stars.
  """

  defp abort(message, excode) do
    IO.puts(:stderr, message)
    System.halt(excode)
  end

  @doc """
  Process input file and display part 1 and 2 solutions.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 1 message is: "GFNKCGGH"
  - Part 2 second is: 10274
  """
  def part12(argv) do
    stars = parse_stars(argv)
    # FIXME should come from argv as option!
    iter_secs = if (List.first(stars) |> elem(0) |> abs()) < 100 do
      10
    else
      50_000
    end
    {second, stars} = iteration_with_min_y_distance(stars, iter_secs)
    if stars == [] do
      raise "no iteration found with all stars"
    end
    IO.puts("Part 1 message is:")
    dump_grid(stars)
    IO.inspect(second, label: "Part 2 second is")
  end

  defp dump_grid(stars) do
    IO.puts("")
    render_to_grid(stars)
    |> Enum.map(fn (line) -> IO.puts(line) end)
    IO.puts("")
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
      _          -> abort('Usage: stars filename', 64)
    end
  end

  defp parse_stars(argv) do
    argv
    |> input_file
    |> File.stream!
    |> Stream.map(&String.trim/1)
    |> Enum.map(&InputParser.parse_line/1)
  end

  @doc """
  Move stars based on velocity.

  ## Parameters

  - stars: List of stars as {x, y, vel_x, vel_y}

  ## Returns

  Updated list of stars

  """
  def move_stars(stars) do
    Enum.map(stars, fn ({x, y, vel_x, vel_y}) ->
      {x + vel_x, y + vel_y, vel_x, vel_y}
    end)
  end

  @doc """
  Calculate dimensions of grid needed to display stars, including some border padding.

  ## Parameters

  - stars: List of stars as {x, y, vel_x, vel_y}

  ## Returns

  Grid dimensions as {min_x, min_y, max_x, max_y}

  """
  def grid_dimensions(stars) do
    {xb, yb} = {2, 1}  # border
    Enum.reduce(stars, {0, 0, 0, 0}, fn ({x, y, _vel_x, _vel_y}, {min_x, min_y, max_x, max_y}) ->
      { min(x-xb, min_x), min(y-yb, min_y), max(x+xb, max_x), max(y+yb, max_y) }
    end)
  end

  @doc """
  Render stars to grid.

  ## Parameters

  - stars: List of stars as {x, y, vel_x, vel_y}

  ## Returns

  List of min_y..max_y grid lines (strings)

  """
  def render_to_grid(stars) do
    star_set = Enum.reduce(stars, MapSet.new(), fn ({x, y, _vel_x, _vel_y}, set) ->
      MapSet.put(set, {x, y})
    end)
    {min_x, min_y, max_x, max_y} = grid_dimensions(stars)
    Enum.reduce(max_y..min_y, [], fn (y, lines) ->
      line = Enum.reduce(max_x..min_x, [], fn (x, chars) ->
        char = if MapSet.member?(star_set, {x, y}), do: ?#, else: ?.
        [char | chars]
      end)
      [line | lines]
    end)
  end

  @doc """
  Find iteration whose star y values are most tightly clustered.

  ## Parameters

  - stars: List of stars as {x, y, vel_x, vel_y}
  - max_seconds: Number of iterations to try

  ## Returns

  {second, stars}

  """
  def iteration_with_min_y_distance(stars, max_seconds) do
    {_, second, stars, _} =
      0..max_seconds
      |> Enum.reduce({1_000_000, nil, [], stars}, fn (sec, {min_y_dist, min_sec, min_stars, stars}) ->
        new_dist = y_dist_of(stars)
        if new_dist < min_y_dist do
          {new_dist, sec, stars, move_stars(stars)}
        else
          {min_y_dist, min_sec, min_stars, move_stars(stars)}
        end
      end)
    {second, stars}
  end

  defp y_dist_of(stars) do
    {min, max} = Enum.reduce(stars, {0, 0}, fn ({_x, y, _vel_x, _vel_y}, {min_y, max_y}) ->
      {min(y, min_y), max(y, max_y)}
    end)
    max - min
  end
end
