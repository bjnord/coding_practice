defmodule Machine do
  @moduledoc """
  Documentation for Machine (Day 19).
  """

  import Machine.CLI
  import Machine.InputParser
  import Machine.CPU

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    cond do
      opts[:disassemble] ->
        disassemble(input_file, opts)
      opts[:decompile] ->
        decompile(input_file, opts)
      true ->
        if Enum.member?(opts[:parts], 1),
          do: part1(input_file, opts)
        if Enum.member?(opts[:parts], 2),
          do: part2(input_file, opts)
    end
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
    IO.puts("Part 1 (icount=#{reg[:icount]} halt=#{Machine.Register.format_i(reg[:halt], opts)})")
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
end
