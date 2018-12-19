defmodule Machine.Executor do
  @doc ~S"""
  Parse the puzzle input.

  ## Returns

  - A set of before/instruction/after samples
  - A set of instructions (test program)

  ## Example

      iex> {samples, _opcodes} = Machine.Executor.parse_input_samples([
      ...>   "Before: [3, 2, 1, 1]\n",
      ...>   "9 2 1 2\n",
      ...>   "After:  [3, 2, 2, 1]\n",
      ...>   "\n",
      ...>   "\n",
      ...>   "\n",
      ...>   "5 2 1 1\n",
      ...>   "4 1 0 0\n",
      ...> ])
      iex> samples
      [
        {{3, 2, 1, 1}, {9, 2, 1, 2}, {3, 2, 2, 1}},
      ]
  """
  def parse_input_samples(lines) when is_list(lines) do
    Stream.cycle([true])
    |> Enum.reduce_while({lines, [], [], :sample}, fn (_t, {lines, samples, opcodes, mode}) ->
      cond do
        lines == [] ->
          {:halt, {samples, opcodes}}
        (mode == :sample) && (List.first(lines) == "\n") ->  # switch modes
          [blank, blank2 | lines] = lines
          if (blank != "\n") || (blank2 != "\n") do
            raise "input file format error, blank=#{blank}"
          end
          {:cont, {lines, samples, opcodes, :opcode}}
        (mode == :sample) ->
          [before, opcode, apres, blank | lines] = lines
          samples = [{parse_baft(before), parse_opcode(opcode), parse_baft(apres)} | samples]
          if blank != "\n" do
            raise "input file format error, blank=#{blank}"
          end
          {:cont, {lines, samples, opcodes, mode}}
        (mode == :opcode) ->
          [opcode | lines] = lines
          opcodes = [parse_opcode(opcode) | opcodes]
          {:cont, {lines, samples, opcodes, mode}}
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

  @opnames [
    :addr, :addi, :mulr, :muli,
    :banr, :bani, :borr, :bori,
    :setr, :seti,
    :gtir, :gtri, :gtrr,
    :eqir, :eqri, :eqrr,
  ]

  @doc """
  Execute test samples, and find matching opcodes for each.

  ## Example

  iex> [{opnum, matches}] = Machine.Executor.find_opcode_matches([
  ...>   {{3, 2, 1, 1}, {9, 2, 1, 2}, {3, 2, 2, 1}},
  ...> ])
  iex> opnum
  9
  iex> matches
  #MapSet<[:addi, :mulr, :seti]>
  """
  def find_opcode_matches(samples) do
    Enum.map(samples, fn ({b4_reg, {opnum, a, b, c}, af_reg}) ->
      matches =
        @opnames
        |> Enum.reduce(MapSet.new(), fn (opname, matches) ->
          if Machine.CPU.execute(mapreg(b4_reg), {opname, a, b, c}) == mapreg(af_reg) do
            MapSet.put(matches, opname)
          else
            matches
          end
        end)
      {opnum, matches}
    end)
  end

  defp mapreg(sample_reg) do
    %{}
    |> Map.put(0, elem(sample_reg, 0))
    |> Map.put(1, elem(sample_reg, 1))
    |> Map.put(2, elem(sample_reg, 2))
    |> Map.put(3, elem(sample_reg, 3))
  end
end
