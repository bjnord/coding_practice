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

  @doc ~S"""
  Is the given equation solvable with `+` `*` and `||` operators?

  ## Parameters

  - `eq`: the equation

  ## Examples
      iex> solvable3?({156, [15, 6]})
      true
      iex> solvable3?({292, [11, 6, 16, 20]})
      true
      iex> solvable3?({7290, [6, 8, 6, 15]})
      true
      iex> solvable3?({21037, [9, 7, 18, 13]})
      false
  """
  @spec solvable3?(equation()) :: boolean()
  def solvable3?({total, [a | t]}) do
    step_solution?(total, steps3(a, t))
  end

  defp steps3(a, t) do
    [
      {a, :+, t},
      {a, :*, t},
      {a, :||, t},
    ]
  end

  defp step_solution?(_total, []) do
    # we have exhausted all steps (equation operator combinations)
    false
  end
  defp step_solution?(total, [{a, op, [b]} | steps]) do
    # next step has just one operation left to perform
    if eval(a, op, b) == total do
      # solution found!
      true
    else
      # continue with next step
      step_solution?(total, steps)
    end
  end
  defp step_solution?(total, [{a, op, [b | t]} | steps]) do
    # next step has more operations after the current one
    new_total = eval(a, op, b)
    if new_total > total do
      # since all operators increase the accumulated value: as soon as we go
      # over the total, we can abandon this branch of the tree, and continue
      # with the next step
      step_solution?(total, steps)
    else
      # prepend new steps (one for each operator type), and continue with
      # the first new step
      step_solution?(total, steps3(new_total, t) ++ steps)
    end
  end

  defp eval(a, op, b) do
    case op do
      :+ -> a + b
      :* -> a * b
      :|| -> op_concat(a, b)
    end
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
    |> Enum.filter(&Bridge.solvable3?/1)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
