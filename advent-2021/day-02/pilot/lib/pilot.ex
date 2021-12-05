defmodule Pilot do
  @moduledoc """
  Documentation for Pilot.
  """

  import Pilot.Parser
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2), do: part2(input_file, opts)
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

  Returns ending `{x, y}` position tuple
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

  Returns ending `{x, y}` position tuple
  """
  def navigate(steps) do
    steps
    |> Enum.reduce({0, 0, 0}, &Pilot.nav_step/2)
    |> Tuple.delete_at(2)
  end

  @doc """
  Do one navigation step. The first tuple is the step instruction, the second is the current position and aim.

  Returns a tuple with the new position and aim.

  ## Examples
      iex> Pilot.nav_step({5, 0}, {0, 0, 0})
      {5, 0, 0}
      iex> Pilot.nav_step({0, 5}, {5, 0, 0})
      {5, 0, 5}
      iex> Pilot.nav_step({8, 0}, {5, 0, 5})
      {13, 40, 5}
      iex> Pilot.nav_step({0, -3}, {13, 40, 5})
      {13, 40, 2}
      iex> Pilot.nav_step({0, 8}, {13, 40, 2})
      {13, 40, 10}
      iex> Pilot.nav_step({2, 0}, {13, 40, 10})
      {15, 60, 10}
  """
  def nav_step({dx, dy}, {x, y, aim}) when dy == 0 do
    # `forward X` does two things:
    # - It increases your horizontal position by X units.
    # - It increases your depth by your aim multiplied by X.
    {x + dx, y + aim * dx, aim}
  end
  def nav_step({dx, dy}, {x, y, aim}) when dx == 0 do
    # `down X` increases your aim by X units.
    # `up X` decreases your aim by X units.
    {x, y, aim + dy}
  end
end
