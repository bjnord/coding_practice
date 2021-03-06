defmodule Machine do
  @moduledoc """
  Documentation for Machine.
  """

  import Machine.Executor
  import Machine.CLI
  import Machine.CPU

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, parts} = parse_args(argv)
    if Enum.member?(parts, 1),
      do: part1(input_file)
    if Enum.member?(parts, 2),
      do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: 640
  """
  def part1(input_file) do
    input_file
    |> parse_input()
    |> elem(0)
    |> find_opcode_matches()
    |> Enum.count(fn ({_opnum, matches}) -> Enum.count(matches) >= 3 end)
    |> IO.inspect(label: "Part 1 sample count is")
  end

  defp parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&(&1))  # FIXME
    |> parse_input_samples()
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: 472
  """
  def part2(input_file) do
    {samples, n_program} = parse_input(input_file)
    opnames = determine_opcode_names(samples)
    program =
      n_program
      |> Enum.map(fn ({opnum, a, b, c}) -> {opnames[opnum], a, b, c} end)
    reg = run_program(program)
    IO.inspect(reg[0], label: "Part 2 register 0 value is")
  end
end
