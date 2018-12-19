defmodule Machine.Executor do
  @doc ~S"""
  Parse the first part of the puzzle input.

  ## Returns

  A set of before/instruction/after samples

  ## Example

      iex> Machine.Executor.parse_input_samples([
      ...>   "Before: [3, 2, 1, 1]\n",
      ...>   "9 2 1 2\n",
      ...>   "After:  [3, 2, 2, 1]\n",
      ...>   "\n",
      ...>   "\n",
      ...>   "\n",
      ...>   "5 2 1 1\n",
      ...>   "4 1 0 0\n",
      ...> ])
      [
        {{3, 2, 1, 1}, {9, 2, 1, 2}, {3, 2, 2, 1}},
      ]
  """
  def parse_input_samples(lines) when is_list(lines) do
    Stream.cycle([true])
    |> Enum.reduce_while({lines, []}, fn (_t, {lines, samples}) ->
      [before | lines] = lines
      cond do
        String.slice(before, 0..5) == "Before" ->
          [opcode, apres, blank | lines] = lines
          samples = [{parse_baft(before), parse_opcode(opcode), parse_baft(apres)} | samples]
          if blank != "\n" do
            raise "input file format error, blank=#{blank}"
          end
          {:cont, {lines, samples}}
        true ->
          {:halt, samples}
      end
    end)
  end

  defp parse_baft(line) do
    baft = Regex.run(~r/\[(\d+),\s+(\d+),\s+(\d+),\s+(\d+)\]/, line)
    [_ | baft] = baft
    Enum.map(baft, &String.to_integer/1)
    |> List.to_tuple
  end

  defp parse_opcode(line) do
    baft = Regex.run(~r/(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/, line)
    [_ | baft] = baft
    Enum.map(baft, &String.to_integer/1)
    |> List.to_tuple
  end
end
