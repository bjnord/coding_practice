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
    {x, y} = argv
    |> input_file
    |> File.read!
    |> String.trim
    |> String.to_integer
    |> largest_power_square
    # coordinates submitted to the puzzle web site must not have spaces!
    IO.inspect("#{x},#{y}", label: "Part 1 largest power 3x3 square is")
  end

  @doc """
  Find 3x3 square with the largest total power.

  ## Parameters

  - grid_serial: Grid serial number (integer)

  ## Returns

  Coordinates of top-left corner of 3x3 square as {x, y} (integers 1..@grid_size)
  """
  def largest_power_square(grid_serial) do
    Enum.reduce(1..@grid_size, %{}, fn (x, acc) ->
      Enum.reduce(1..@grid_size, acc, fn (y, acc) ->
        power = power_level({x, y}, grid_serial)
        Enum.reduce(contributes_to_cells({x, y}), {acc, power}, fn ({x0, y0}, {acc, power}) ->
          {Map.update(acc, {x0, y0}, power, &(&1 + power)), power}
        end)
        |> elem(0)
      end)
    end)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
  end

  defp contributes_to_cells({x, y}) do
    Enum.flat_map(max(1, x-2)..x, fn (i) ->
      Enum.map(max(1, y-2)..y, fn (j) -> {i, j} end)
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
