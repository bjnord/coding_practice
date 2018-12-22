defmodule Machine do
  @moduledoc """
  Documentation for Machine (Day 19).
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
  Process input file and display disassembled program.
  """
  def disassemble(input_file, opts \\ []) do
    lines =
      input_file
      |> parse_input()
      |> disassemble_program(opts)
    IO.puts(:stderr, "Disassembled #{input_file} program:")
    lines
    |> Enum.map(fn (line) -> IO.puts(line) end)
  end

  @doc """
  Process input file and display decompiled program.
  """
  def decompile(input_file, opts \\ []) do
    lines =
      input_file
      |> parse_input()
      |> decompile_program(opts)
    IO.puts(:stderr, "Decompiled #{input_file} program:")
    lines
    |> Enum.map(fn (line) -> IO.puts(line) end)
  end

  defp parse_initial(i) do
    cond do
      i == nil ->
        0
      String.slice(i, 0..1) == "0x" ->
        String.to_integer(String.slice(i, 2..-1), 16)
      String.slice(i, 0..1) == "0o" ->
        String.to_integer(String.slice(i, 2..-1), 8)
      true ->
        String.to_integer(i)
    end
  end
end
