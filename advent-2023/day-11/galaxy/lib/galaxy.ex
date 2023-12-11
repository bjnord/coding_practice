defmodule Galaxy do
  @moduledoc """
  Documentation for `Galaxy`.
  """

  import Galaxy.Parser
  import Snow.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    parse_input(input_file)
    nil  # TODO
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc ~S"""
  Find the maximum Y and X values for an image.

  ## Parameters

  `positions` - list of positions (`{y, x}` tuples)

  Returns a `{max_y, max_x}` tuple.

  ## Examples
      iex> Galaxy.max([{0, 1}, {0, 4}, {2, 0}])
      {2, 4}
  """
  def max(positions) do
    positions
    |> Enum.reduce({0, 0}, fn {y, x}, {max_y, max_x} ->
      {max(y, max_y), max(x, max_x)}
    end)
  end
end
