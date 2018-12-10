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

  - Part 1 answer is: ...
  """
  def part1(argv) do
    parse_stars(argv)
    |> IO.inspect(label: "Part 1 foo is")
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
  Render stars to grid.

  ## Parameters

  - stars: List of stars as {pos_x, pos_y, vel_x, vel_y}
  - grid_dim: Grid dimension as {min_x, min_y, max_x, max_y}

  ## Returns

  List of min_y..max_y grid lines (strings)

  """
  def render_to_grid(stars, {min_x, min_y, max_x, max_y}) do
    star_set = Enum.reduce(stars, MapSet.new(), fn ({pos_x, pos_y, _vel_x, _vel_y}, set) ->
      MapSet.put(set, {pos_x, pos_y})
    end)
    Enum.reduce(min_y..max_y, [], fn (y, lines) ->
      line = Enum.reduce(min_x..max_x, [], fn (x, chars) ->
        char = if MapSet.member?(star_set, {x, y}), do: ?#, else: ?.
        [char | chars]
      end)
      |> Enum.reverse
      [line | lines]
    end)
    |> Enum.reverse
  end
end
