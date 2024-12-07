defmodule Bridge do
  @moduledoc """
  Documentation for `Bridge`.
  """

  import Bridge.Parser
  import History.CLI

  @type equation() :: {integer(), [integer()]}

  @doc ~S"""
  Is the given equation solvable with `+` and `*` operators?

  ## Parameters

  - `eq`: the equation

  ## Examples
      iex> atom_solvable?({156, [15, 6]})
      false
      iex> atom_solvable?({292, [11, 6, 16, 20]})
      true
      iex> atom_solvable?({7290, [6, 8, 6, 15]})
      false
      iex> atom_solvable?({21037, [9, 7, 18, 13]})
      false
  """
  @spec atom_solvable?(equation()) :: boolean()
  def atom_solvable?({total, [v | t]}) do
    form_equations(t, [v])
    |> History.flatten_2d()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.any?(&(operable?(total, &1)))
  end

  defp form_equations([], elements), do: elements
  defp form_equations([v | t], elements) do
    [
      [v, :+ | elements],
      [v, :* | elements],
    ]
    |> Enum.map(&(form_equations(t, &1)))
  end

  defp operable?(total, [a]), do: a == total
  defp operable?(total, [a, op, b | t]) do
    case op do
      :+ -> operable?(total, [a + b | t])
      :* -> operable?(total, [a * b | t])
      :|| -> operable?(total, [op_concat(a, b) | t])
    end
  end

  @doc ~S"""
  Concatenation operator

  ## Parameters

  - `a`: the first value
  - `b`: the first value

  ## Returns

  an integer with the digits of `a` and `b` concatenated

  ## Examples
      iex> op_concat(2, 3)
      23
      iex> op_concat(867, 5309)
      8675309
  """
  @spec op_concat(integer(), integer()) :: integer()
  def op_concat(a, b) do
    "#{a}#{b}"
    |> String.to_integer()
  end

  @doc ~S"""
  Is the given equation solvable with `+` `*` and `||` operators?

  ## Parameters

  - `eq`: the equation

  ## Examples
      iex> atom_solvable3?({156, [15, 6]})
      true
      iex> atom_solvable3?({292, [11, 6, 16, 20]})
      true
      iex> atom_solvable3?({7290, [6, 8, 6, 15]})
      true
      iex> atom_solvable3?({21037, [9, 7, 18, 13]})
      false
  """
  @spec atom_solvable3?(equation()) :: boolean()
  def atom_solvable3?({total, [v | t]}) do
    form_equations3(t, [v])
    |> History.flatten_2d()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.any?(&(operable?(total, &1)))
  end

  defp form_equations3([], elements), do: elements
  defp form_equations3([v | t], elements) do
    [
      [v, :+ | elements],
      [v, :* | elements],
      [v, :|| | elements],
    ]
    |> Enum.map(&(form_equations3(t, &1)))
  end

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Enum.filter(&Bridge.atom_solvable?/1)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Enum.filter(&Bridge.atom_solvable3?/1)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
