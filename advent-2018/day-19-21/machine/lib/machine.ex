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
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1),
      do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2),
      do: part2(input_file, opts)
    if Enum.member?(opts[:parts], 3),
      do: part3(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: 1152
  """
  def part1(input_file, opts \\ []) do
    reg =
      input_file
      |> parse_input()
      |> run_program(opts)
    IO.inspect(reg[0], label: "Part 1 register 0 value is")
  end

  defp parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&(&1))  # FIXME
    |> parse_input_program()
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file, opts \\ []) do
    reg =
      input_file
      |> parse_input()
      |> run_program(opts ++ [initial_r0: 1])
    IO.inspect(reg[0], label: "Part 2 register 0 value is")
  end

  @doc """
  Process input file and display part 3 solution.

  This disassembles the input file program.
  """
  def part3(input_file, opts \\ []) do
    lines =
      input_file
      |> parse_input()
      |> disassemble_program(opts)
    IO.puts("Part 3 program is:")
    lines
    |> Enum.map(fn (line) -> IO.puts(line) end)
  end
end
