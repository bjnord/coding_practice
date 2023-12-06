defmodule Race do
  @moduledoc """
  Documentation for `Race`.
  """

  import Race.Parser
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
    |> Enum.map(&Race.n_wins/1)
    |> Enum.product()
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
  Calculate race distances.

  ## Parameters

  - `time` - length of race (in milliseconds)

  Returns a list of race distances (in millimeters).

  ## Examples
      iex> Race.distances(3)
      [0, 2, 2, 0]
  """
  def distances(time) do
    for t <- 0..time do
      (time - t) * t
    end
  end

  @doc ~S"""
  Calculate number of winning races.

  ## Parameters

  - `time` - length of race (in milliseconds)
  - `record` - record race distance (in millimeters)

  Returns the number of winning races.

  ## Examples
      iex> Race.n_wins({3, 1})
      2
  """
  def n_wins({time, record}) do
    distances(time)
    |> Enum.count(fn dist -> dist > record end)
  end
end
