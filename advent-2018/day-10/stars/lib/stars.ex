defmodule Stars do
  @moduledoc """
  Documentation for Stars.
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

  - Part 1 answer is: "GFNKCGGH"
  """
  def part1(argv) do
    stars = parse_stars(argv)
    # FIXME should come from argv as option!
    {grid_dim, iter_secs} = if (List.first(stars) |> elem(0) |> abs()) < 100 do
      {{-6, -4, 15, 11}, 10}
    else
      {{-320, -240, 319, 239}, 50_000}
    end
    {second, stars} = iteration_with_min_y_distance(stars, grid_dim, iter_secs)
    if stars == [] do
      raise "no iteration found with all stars"
    end
    dump_grid(second, stars, grid_dim)
  end

  defp dump_grid(sec, stars, grid_dim) do
    IO.puts("")
    case sec do
      0 -> IO.puts("Initially:")
      1 -> IO.puts("After 1 second:")
      _ -> IO.puts("After #{sec} seconds:")
    end
    render_to_grid(stars, grid_dim)
    |> Enum.map(fn (line) -> IO.puts(line) end)
  end

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(argv) do
    parse_stars(argv)
    |> IO.inspect(label: "Part 2 foo is")
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

  - stars: List of stars as {pos_x, pos_y, vel_x, vel_y}

  ## Returns

  Updated list of stars

  """
  def move_stars(stars) do
    Enum.map(stars, fn ({pos_x, pos_y, vel_x, vel_y}) ->
      {pos_x + vel_x, pos_y + vel_y, vel_x, vel_y}
    end)
  end

  @doc """
  Are all stars visible within grid dimensions?

  ## Parameters

  - stars: List of stars as {pos_x, pos_y, vel_x, vel_y}
  - grid_dim: Grid dimensions as {min_x, min_y, max_x, max_y}

  ## Returns

  Updated list of stars

  """
  def stars_visible?(stars, grid_dim) do
    Enum.reduce_while(stars, true, fn (star, _visible) ->
      case star_visible?(star, grid_dim) do
        true  -> {:cont, true}
        false -> {:halt, false}
      end
    end)
  end

  defp star_visible?({x, y, _vel_x, _vel_y}, {min_x, min_y, max_x, max_y}) do
    (x >= min_x) && (y >= min_y) && (x <= max_x) && (y <= max_y)
  end

  @doc """
  Render stars to grid.

  ## Parameters

  - stars: List of stars as {pos_x, pos_y, vel_x, vel_y}
  - grid_dim: Grid dimensions as {min_x, min_y, max_x, max_y}

  ## Returns

  List of min_y..max_y grid lines (strings)

  """
  def render_to_grid(stars, {min_x, min_y, max_x, max_y}) do
    star_set = Enum.reduce(stars, MapSet.new(), fn ({pos_x, pos_y, _vel_x, _vel_y}, set) ->
      MapSet.put(set, {pos_x, pos_y})
    end)
    Enum.reduce(max_y..min_y, [], fn (y, lines) ->
      line = Enum.reduce(max_x..min_x, [], fn (x, chars) ->
        char = if MapSet.member?(star_set, {x, y}), do: ?#, else: ?.
        [char | chars]
      end)
      [line | lines]
    end)
  end

  @doc """
  Find iteration with visible stars whose y values are most tightly clustered.

  ## Parameters

  - stars: List of stars as {pos_x, pos_y, vel_x, vel_y}
  - grid_dim: Grid dimensions as {min_x, min_y, max_x, max_y}
  - max_seconds: Number of iterations to try

  ## Returns

  {second, stars}

  """
  def iteration_with_min_y_distance(stars, {min_x, min_y, max_x, max_y}, max_seconds) do
    {_, second, stars, _} = 0..max_seconds
    |> Enum.reduce({max_y-min_y+1, -1, [], stars}, fn (sec, {min_y_dist, min_sec, min_stars, stars}) ->
      case stars_visible?(stars, {min_x, min_y, max_x, max_y}) do
        true ->
          new_dist = y_dist_of(stars)
          if new_dist < min_y_dist do
            {new_dist, sec, stars, move_stars(stars)}
          else
            {min_y_dist, min_sec, min_stars, move_stars(stars)}
          end
        false ->
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
