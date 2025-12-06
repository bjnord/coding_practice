defmodule Trash do
  @moduledoc """
  Documentation for `Trash`.
  """

  @type equation() :: {[integer()], atom()}

  import Trash.Parser
  import Decor.CLI

  @doc """
  Solve an equation.
  """
  @spec solve(equation()) :: integer()
  def solve({[operand1 | operands], operation}) do
    operands
    |> Enum.reduce(operand1, fn operand, acc ->
      compute(acc, operand, operation)
    end)
  end

  @spec compute(integer(), integer(), atom()) :: integer()
  defp compute(op1, op2, operation) do
    case operation do
      :+ -> op1 + op2
      :* -> op1 * op2
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
    |> Enum.map(&solve/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
