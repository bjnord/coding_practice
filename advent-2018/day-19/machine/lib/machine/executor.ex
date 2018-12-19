defmodule Machine.Executor do
  @doc ~S"""
  Parse the puzzle input.

  ## Returns

  - A set of before/instruction/after samples
  - A set of instructions (test program)

  ## Example

      iex> Machine.Executor.parse_input_program([
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
end
