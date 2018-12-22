defmodule Machine.InputParser do
  import Machine.CPU

  @doc ~S"""
  Parse the puzzle input.

  ## Returns

  - A set of before/instruction/after samples
  - A set of instructions (test program)

  ## Example

      iex> Machine.InputParser.parse_input_program([
      ...>   "#ip 0\n",
      ...>   "seti 5 0 1\n",
      ...>   "addi 0 1 0\n",
      ...> ])
      %{
        :ip => 0,
        0 => {:seti, 5, 0, 1},
        1 => {:addi, 0, 1, 0},
      }
  """
  def parse_input_program(lines) when is_list(lines) do
    Stream.cycle([true])
    |> Enum.reduce_while({lines, %{}, 0}, fn (_t, {lines, program, addr}) ->
      cond do
        lines == [] ->
          {:halt, program}
        true ->
          [line | lines] = lines
          if String.slice(line, 0..3) == "#ip " do
            {:cont, {lines, Map.put(program, :ip, parse_ipbind(line)), addr}}
          else
            {:cont, {lines, Map.put(program, addr, parse_opcode(line)), addr+1}}
          end
      end
    end)
  end

  defp parse_ipbind(line) do
    [_, ipbind] =
      Regex.run(~r/#ip\s+(\d+)/, line)
    String.to_integer(ipbind)
  end

  defp parse_opcode(line) do
    [_, opname, arg1, arg2, arg3] =
      Regex.run(~r/(\w+)\s+(\d+)\s+(\d+)\s+(\d+)/, line)
    {String.to_atom(opname), String.to_integer(arg1), String.to_integer(arg2), String.to_integer(arg3)}
  end

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&(&1))  # FIXME
    |> parse_input_program()
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
end
