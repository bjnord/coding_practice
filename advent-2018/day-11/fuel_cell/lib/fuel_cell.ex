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
    |> square_powers(3..3)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
    # coordinates submitted to the puzzle web site must not have spaces!
    IO.inspect("#{x},#{y}", label: "Part 1 largest power 3x3 square is")
  end

  @doc """
  Compute total power of ZxZ squares.

  ## Parameters

  - grid_serial: Grid serial number (integer)
  - z_range: Range of square sizes (integer range)

  ## Returns

  Map of power values:

  - key: coordinates + size of top-left corner of square as {x, y, z} (integers 1..@grid_size)
  - value: total power of square (integer)
  """
  def square_powers(grid_serial, min_z..max_z) do
    # must compute 1..max_z (since algorithm is recursive)
    square_powers_for_z(grid_serial, max_z)
    # ...but only return squares of interest (filter by range caller provided)
    |> Enum.filter(fn ({{_x, _y, z}, _power}) -> Enum.member?(min_z..max_z, z) end)
  end

  defp square_powers_for_z(grid_serial, 1) do
    Enum.reduce(1..@grid_size, %{}, fn (x, acc) ->
      Enum.reduce(1..@grid_size, acc, fn (y, acc) ->
        # total power of 1x1 squares is just the square's own power
        Map.put(acc, {x, y, 1}, power_level({x, y}, grid_serial))
      end)
    end)
  end

  defp square_powers_for_z(grid_serial, z) do
    smaller_acc = square_powers_for_z(grid_serial, z-1)
    Enum.reduce(1..@grid_size-(z-1), %{}, fn (x, acc) ->
      Enum.reduce(1..@grid_size-(z-1), acc, fn (y, acc) ->
        # total power of ZxZ squares is
        # - total power of (Z-1)x(Z-1) square at this location
        square_power = smaller_acc[{x, y, z-1}]
        # - plus total power of Zx1 edge below that square
        x_edge = Enum.map(x..x+(z-1), fn (xi) -> power_level({xi, y+(z-1)}, grid_serial) end)
        # - plus total power of 1x(Z-1) edge to the right of that square
        #   (note that it's Z-1, so we don't double-count the corner)
        y_edge = Enum.map(y..y+(z-2), fn (yj) -> power_level({x+(z-1), yj}, grid_serial) end)
        Map.put(acc, {x, y, z}, square_power + Enum.sum(x_edge) + Enum.sum(y_edge))
      end)
    end)
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
    |> File.read!
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

  @doc """
  Hello world.

  ## Examples

      iex> FuelCell.hello
      :world

  """
  def hello do
    :world
  end
end
