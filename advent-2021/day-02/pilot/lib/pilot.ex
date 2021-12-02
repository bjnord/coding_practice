defmodule Pilot do
  @moduledoc """
  Documentation for Pilot.
  """

  import Pilot.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1),
      do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2),
      do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts \\ []) do
    {x, y} = input_file
             |> parse_input(opts)
             |> navigate_naïvely
    IO.inspect(x * y, label: "Part 1 answer is")
  end

  @doc """
  Navigate using the (incorrect) part 1 method.
  """
  def navigate_naïvely(steps) do
   Enum.reduce(steps, {0, 0}, fn ({dx, dy}, {x, y}) ->
     {dx + x, dy + y}
   end)
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    {x, y} = input_file
             |> parse_input(opts)
             |> navigate
    IO.inspect(x * y, label: "Part 2 answer is")
  end

  @doc """
  Navigate using the (correct) part 2 method.

  - `down X` increases your aim by X units.
  - `up X` decreases your aim by X units.
  - `forward X` does two things:
    - It increases your horizontal position by X units.
    - It increases your depth by your aim multiplied by X.
  """
  def navigate(steps) do
    # FIXME extract reduce fn to defp, add tests (and properties?) for it
    {x, y, _} = Enum.reduce(steps, {0, 0, 0}, fn ({dx, dy}, {x, y, aim}) ->
                  if dy == 0 do
                    {x + dx, y + aim * dx, aim}
                  else
                    {x, y, aim + dy}
                  end
                end)
    {x, y}
  end
end
