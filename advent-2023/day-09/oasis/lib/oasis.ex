defmodule Oasis do
  @moduledoc """
  Documentation for `Oasis`.
  """

  require Logger
  import Oasis.Parser
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
    |> Enum.map(&Oasis.predicted/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    |> Enum.map(&Oasis.prev_predicted/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc ~S"""
  Find the pairwise differences for a list of values.

  ## Parameters

  - `values` - the list of values (integer)
  - `dir` - direction of travel (`:forward` or `:reverse`)

  Returns a list of pairwise difference values (integers).

  ## Examples
      iex> calc_differences([2, 4, 6, 8], :forward)
      [2, 2, 2]
      iex> calc_differences([19, 15, 12, 10, 9], :reverse)
      [4, 3, 2, 1]
  """
  def calc_differences(values, dir) when dir == :forward do
    values
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end
  def calc_differences(values, dir) when dir == :reverse do
    values
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> a - b end)
  end

  @doc ~S"""
  Find the predicted next value for a list of values.

  ## Parameters

  - `values` - the list of values (integer)

  Returns the predicted next value (integer)

  ## Examples
      iex> predicted([2, 4, 6, 8])
      10
  """
  def predicted(values) do
    values0 = Enum.reverse(values)
    Logger.debug("A initial #{inspect(values0)}")
    differences =
      Stream.cycle([true])
      |> Enum.reduce_while({values0, [values0]}, fn _, {values, acc} ->
        new_values = calc_differences(values, :reverse)
        Logger.debug("A next #{inspect(new_values)}")
        if Enum.all?(new_values, fn v -> v == 0 end) do
          {:halt, [new_values | acc]}
        else
          {:cont, {new_values, [new_values | acc]}}
        end
      end)
    Logger.debug("A final #{inspect(differences)}")
    result =
      differences
      |> Enum.reduce([], fn values, acc ->
        if acc == [] do
          new_values = [0 | values]
          Logger.debug("B initial #{inspect(new_values)}")
          [new_values]
        else
          v = List.first(List.first(acc))
          new_values = [List.first(values) + v | values]
          Logger.debug("B next #{inspect(new_values)}")
          [new_values | acc]
        end
      end)
    Logger.debug("B final #{inspect(result)}")
    result
    |> List.first()
    |> List.first()
  end

  @doc ~S"""
  Find the predicted previous value for a list of values.

  ## Parameters

  - `values` - the list of values (integer)

  Returns the predicted next value (integer)

  ## Examples
      iex> prev_predicted([2, 4, 6, 8])
      0
  """
  def prev_predicted(values) do
    Logger.debug("C initial #{inspect(values)}")
    differences =
      Stream.cycle([true])
      |> Enum.reduce_while({values, [values]}, fn _, {values, acc} ->
        new_values = calc_differences(values, :forward)
        Logger.debug("C next #{inspect(new_values)}")
        if Enum.all?(new_values, fn v -> v == 0 end) do
          {:halt, [new_values | acc]}
        else
          {:cont, {new_values, [new_values | acc]}}
        end
      end)
    Logger.debug("C final #{inspect(differences)}")
    result =
      differences
      |> Enum.reduce([], fn values, acc ->
        if acc == [] do
          new_values = [0 | values]
          Logger.debug("D initial #{inspect(new_values)}")
          [new_values]
        else
          v = List.first(List.first(acc))
          new_values = [List.first(values) - v | values]
          Logger.debug("D next #{inspect(new_values)}")
          [new_values | acc]
        end
      end)
    Logger.debug("D final #{inspect(result)}")
    result
    |> List.first()
    |> List.first()
  end
end
