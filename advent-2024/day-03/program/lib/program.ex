defmodule Program do
  @moduledoc """
  Documentation for `Program`.
  """

  import History.CLI
  import Program.Parser

  def process_mul(instructions) do
    instructions
    |> Enum.map(fn inst ->
      {op, opands} = inst
      case op do
        :mul ->
          [a, b] = opands
          a * b
        :do ->
          0
        :"don't" ->
          0
      end
    end)
    |> Enum.sum()
  end

  def process_all(instructions) do
    instructions
    |> Enum.reduce({0, true}, fn inst, {acc, enabled} ->
      {op, opands} = inst
      case op do
        :mul ->
          [a, b] = opands
          if enabled do
            {acc + a * b, true}
          else
            {acc, false}
          end
        :do ->
          {acc, true}
        :"don't" ->
          {acc, false}
      end
    end)
    |> elem(0)
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
    |> process_mul()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> process_all()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
