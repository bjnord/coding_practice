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
    if opts[:disassemble] do
      disassemble(input_file, opts)
    else
      if Enum.member?(opts[:parts], 1),
        do: day19_part1(input_file, opts)
      if Enum.member?(opts[:parts], 2),
        do: day19_part2(input_file, opts)
      if Enum.member?(opts[:parts], 5),
        do: day21_part1(input_file, opts)
      if Enum.member?(opts[:parts], 6),
        do: day21_part2(input_file, opts)
    end
  end

  @doc """
  Process input file and display day 19 part 1 solution.

  ## Correct Answer

  - Day 19 Part 1 answer is: 1152
  """
  def day19_part1(input_file, opts \\ []) do
    reg =
      input_file
      |> parse_input()
      |> run_program(opts)
    IO.inspect(reg[0], label: "Day 19 Part 1 (icount=#{reg[:icount]}) register 0 value is")
  end

  defp parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&(&1))  # FIXME
    |> parse_input_program()
  end

  @doc """
  Process input file and display day 19 part 2 solution.

  ## Correct Answer

  - Day 19 Part 2 answer is: ...
  """
  def day19_part2(input_file, opts \\ []) do
    reg =
      input_file
      |> parse_input()
      |> run_program(opts ++ [initial_r0: 1])
    IO.inspect(reg[0], label: "Day 19 Part 2 register 0 value is")
  end

  @doc """
  Process input file and display disassembled program.
  """
  def disassemble(input_file, opts \\ []) do
    lines =
      input_file
      |> parse_input()
      |> disassemble_program(opts)
    IO.puts("Disassembled #{input_file} program:")
    lines
    |> Enum.map(fn (line) -> IO.puts(line) end)
  end

  @doc """
  Process input file and display day 21 part 1 solution.

  ## Correct Answer

  - Day 21 Part 1 answer is: 202209
  """
  def day21_part1(input_file, opts \\ []) do
    i_r0 = 0x0315E1
    reg =
      input_file
      |> parse_input()
      |> run_program(opts ++ [initial_r0: i_r0])
    IO.inspect(i_r0, label: "Day 21 Part 1 (icount=#{reg[:icount]}) initial register 0 value is")
  end

  @doc """
  Process input file and display day 21 part 2 solution.

  ## Correct Answer

  - Day 21 Part 2 answer is: ...
  """
  def day21_part2(input_file, opts \\ []) do
    i_r0 =
      if opts[:initial] do
        parse_initial(opts[:initial])
      else
        # TODO replace with correct part 2 answer
        0x0315E1
      end
    reg =
      input_file
      |> parse_input()
      |> run_program(opts ++ [initial_r0: i_r0])
    IO.inspect(i_r0, label: "Day 21 Part 2 (icount=#{reg[:icount]}) initial register 0 value is")
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
