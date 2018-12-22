defmodule Gadget do
  @moduledoc """
  Documentation for Gadget (a clone of "Machine" for Day 21).
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

  - Part 1 answer is: 202209 (0x0315E1)
  """
  def part1(input_file, opts \\ []) do
    i_r0 = 0x0315E1
    reg =
      input_file
      |> parse_input()
      |> run_program(opts ++ [initial_r0: i_r0])
    IO.inspect(i_r0, label: "Part 1 initial register 0 lower bound is")
    IO.puts("Part 1 (icount=#{reg[:icount]} halt=#{Machine.Register.format_i(reg[:halt], opts)})")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: 11777564 (0xB3B61C)
  """
  def part2(input_file, opts \\ []) do
    i_r0 =
      if opts[:initial] do
        parse_initial(opts[:initial])
      else
        0xB3B61C
      end
    reg =
      input_file
      |> parse_input()
      |> run_program(opts ++ [initial_r0: i_r0])
    IO.inspect(i_r0, label: "Part 2 initial register 0 upper bound is")
    IO.puts("Part 2 (icount=#{reg[:icount]} halt=#{Machine.Register.format_i(reg[:halt], opts)})")
  end
end
