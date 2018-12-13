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
    sat = grid_serial_no(argv)
          |> power_values()
          |> SummedArea.new({1..@grid_size, 1..@grid_size})
    {3, x, y} = max_power_square(3..3, sat)
    # coordinates submitted to the puzzle web site must not have spaces!
    IO.inspect("#{x},#{y}", label: "Part 1 largest-power 3x3 square is")
  end

  defp grid_serial_no(argv) do
    argv
    |> input_file
    |> File.read!
    |> String.trim
    |> String.to_integer
  end

  defp power_values(grid_serial) do
    # TODO try comprehension-into-map here
    Enum.reduce(1..@grid_size, %{}, fn (x, acc) ->
      Enum.reduce(1..@grid_size, acc, fn (y, acc) ->
        Map.put(acc, {x, y}, power_level({x, y}, grid_serial))
      end)
    end)
  end

  @doc """
  Find square with the largest total power.

  ## Parameters

  - z_range: Range of square sizes (integer range)
  - sat: (see SummedArea module for details)

  ## Returns

  Size + coordinates of top-left corner of square as {z, x, y} (integers 1..@grid_size)
  """
  def max_power_square(z_range, sat) do
    squares =
      for z <- z_range,
        x <- 1..@grid_size-(z-1),
        y <- 1..@grid_size-(z-1),
        do: {z, x, y}
    Enum.max_by(squares, fn ({z, x, y}) -> SummedArea.area(sat, {x, y}, {z, z}) end)
  end

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 answer is: "231,108,14"
  """
  def part2(argv) do
    sat = grid_serial_no(argv)
          |> power_values()
          |> SummedArea.new({1..@grid_size, 1..@grid_size})
    {z, x, y} = max_power_square(1..@grid_size, sat)
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
      _          -> abort('Usage: fuel_cell filename', 64)
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
