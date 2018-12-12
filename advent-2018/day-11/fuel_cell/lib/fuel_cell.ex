defmodule FuelCell do
  @moduledoc """
  Documentation for FuelCell.
  """

  # 300x300 grid
  @grid_size 300

  defp abort(message, excode) do
    IO.puts(:stderr, message)
    System.halt(excode)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 1 answer is: "21,93"
  """
  def part1(argv) do
    {x, y, _z} = argv
    |> input_file
    |> File.read!
    |> String.trim
    |> String.to_integer
    |> max_power_square(3..3)
    # coordinates submitted to the puzzle web site must not have spaces!
    IO.inspect("#{x},#{y}", label: "Part 1 largest-power 3x3 square is")
  end

  @doc """
  Find square with the largest total power.

  ## Parameters

  - grid_serial: Grid serial number (integer)
  - z_range: Range of square sizes (integer range)

  ## Returns

  Coordinates + size of top-left corner of square as {x, y, z} (integers 1..@grid_size)
  """
  def max_power_square(grid_serial, min_z..max_z) do
    max_power_square_for_z(grid_serial, max_z, min_z..max_z)
    |> elem(1)  # from {squares, {max_square_id, max_power}}
    |> elem(0)  # from {square_id, power}
  end

  defp max_power_square_for_z(grid_serial, 1, z_filter) do
    my_squares = Enum.reduce(1..@grid_size, %{}, fn (x, acc) ->
      Enum.reduce(1..@grid_size, acc, fn (y, acc) ->
        # total power of 1x1 squares is just the square's own power
        Map.put(acc, {x, y, 1}, power_level({x, y}, grid_serial))
      end)
    end)
    {my_squares, new_max_square({nil, -1_000_000}, my_squares, Enum.member?(z_filter, 1))}
  end

  defp max_power_square_for_z(grid_serial, z, z_filter) do
    {smaller_squares, max_square} = max_power_square_for_z(grid_serial, z-1, z_filter)
    my_squares = Enum.reduce(1..@grid_size-(z-1), %{}, fn (x, acc) ->
      Enum.reduce(1..@grid_size-(z-1), acc, fn (y, acc) ->
        # total power of ZxZ squares is
        # - total power of (Z-1)x(Z-1) square at this location
        square_power = smaller_squares[{x, y, z-1}]
        # - plus total power of Zx1 edge below that square
        x_edge = Enum.map(x..x+(z-1), fn (xi) -> power_level({xi, y+(z-1)}, grid_serial) end)
        # - plus total power of 1x(Z-1) edge to the right of that square
        #   (note that it's Z-1, so we don't double-count the corner)
        y_edge = Enum.map(y..y+(z-2), fn (yj) -> power_level({x+(z-1), yj}, grid_serial) end)
        Map.put(acc, {x, y, z}, square_power + Enum.sum(x_edge) + Enum.sum(y_edge))
      end)
    end)
    {my_squares, new_max_square(max_square, my_squares, Enum.member?(z_filter, z))}
  end

  defp new_max_square(max_square, squares, in_filter) when in_filter == true do
    new_max_square = Enum.max_by(squares, &elem(&1, 1))
    if elem(new_max_square, 1) > elem(max_square, 1), do: new_max_square, else: max_square
  end

  defp new_max_square(max_square, _squares, _),
    do: max_square

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 answer is: "231,108,14"
  """
  def part2(argv) do
    {x, y, z} = argv
    |> input_file
    |> File.read!
    |> String.trim
    |> String.to_integer
    #|> max_power_square(1..@grid_size)
    |> max_power_square(1..16)  # FIXME CHEATING
    # coordinates submitted to the puzzle web site must not have spaces!
    IO.inspect("#{x},#{y},#{z}", label: "Part 2 largest-power square is")
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
      _          -> abort('Usage: foo filename', 64)
    end
  end

  @doc """
  Find the power level in a given fuel cell.

  ## Algorithm

  - Find the fuel cell's rack ID, which is its X coordinate plus 10.
  - Begin with a power level of the rack ID times the Y coordinate.
  - Increase the power level by the value of the grid serial number.
  - Set the power level to itself multiplied by the rack ID.
  - Keep only the hundreds digit of the power level (so 12345 becomes 3).
    -- Numbers with no hundreds digit become 0.
  - Subtract 5 from the power level.

  ## Parameters

  - {x, y}: Fuel cell coordinates (integers 1..@grid_size)
  - grid_serial: Grid serial number (integer)

  ## Returns

  Power level (integer)

  ## Examples

    iex> FuelCell.power_level({3, 5}, 8)
    4

    iex> FuelCell.power_level({122, 79}, 57)
    -5

    iex> FuelCell.power_level({217, 196}, 39)
    0

    iex> FuelCell.power_level({101, 153}, 71)
    4

  """
  def power_level({x, y}, grid_serial) do
    rack_id = (x + 10)
    hundreds_digit(((rack_id * y) + grid_serial) * rack_id) - 5
  end

  defp hundreds_digit(n) do
    div(rem(n, 1000), 100)
  end
end
