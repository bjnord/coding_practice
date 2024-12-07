defmodule Bridge do
  @moduledoc """
  Documentation for `Bridge`.
  """

  import Bridge.Parser
  import History.CLI

  @type equation() :: {integer(), [integer()]}

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
  Is the given equation solvable with the given operators?

  ## Parameters

  - `equation`: the equation
  - `operators`: the operators

  ## Examples
      iex> solvable?({156, [15, 6]}, [:+, :*])
      false
      iex> solvable?({156, [15, 6]}, [:+, :*, :||])
      true
      iex> solvable?({292, [11, 6, 16, 20]}, [:+, :*])
      true
      iex> solvable?({292, [11, 6, 16, 20]}, [:+, :*, :||])
      true
      iex> solvable?({21037, [9, 7, 18, 13]}, [:+, :*, :||])
      false
  """
  @spec solvable?(equation(), [atom()]) :: boolean()
  def solvable?(equation, operators)
  def solvable?({total, [a | t]}, operators) do
    step_solution?(total, operators, steps(a, operators, t))
  end

  defp steps(a, operators, t) do
    operators
    |> Enum.map(&({a, &1, t}))
  end

  defp step_solution?(_total, _operators, []) do
    # we have exhausted all steps in queue (equation operator combinations)
    false
  end
  defp step_solution?(total, operators, [{a, op, [b]} | queue]) do
    # next step has just one operation left to perform
    if eval(a, op, b) == total do
      # solution found!
      true
    else
      # continue with next step in queue
      step_solution?(total, operators, queue)
    end
  end
  defp step_solution?(total, operators, [{a, op, [b | t]} | queue]) do
    # next step has more operations after the current one
    new_total = eval(a, op, b)
    if new_total > total do
      # since all operators increase the accumulated value: as soon as we go
      # over the total, we can abandon this branch of the tree, and continue
      # with next step in queue
      step_solution?(total, operators, queue)
    else
      # prepend new steps (one for each operator type), and continue with
      # next (new) step in queue
      step_solution?(total, operators, steps(new_total, operators, t) ++ queue)
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
    |> Enum.filter(&(Bridge.solvable?(&1, [:+, :*])))
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Enum.filter(&(Bridge.solvable?(&1, [:+, :*, :||])))
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
