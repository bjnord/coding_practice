defmodule Machine.Executor do
  import Machine.Register

  @doc ~S"""
  Parse the puzzle input.

  ## Returns

  - A set of before/instruction/after samples
  - A set of instructions (test program)

  ## Example

      iex> {samples, program} = Machine.Executor.parse_input_samples([
      ...>   "Before: [3, 2, 1, 1]\n",
      ...>   "9 2 1 2\n",
      ...>   "After:  [3, 2, 2, 1]\n",
      ...>   "\n",
      ...>   "\n",
      ...>   "\n",
      ...>   "10 2 1 2\n",
      ...>   "5 2 1 1\n",
      ...>   "4 1 0 0\n",
      ...> ])
      iex> samples
      [
        {{3, 2, 1, 1}, {9, 2, 1, 2}, {3, 2, 2, 1}},
      ]
      iex> program
      [
        {10, 2, 1, 2}, {5, 2, 1, 1}, {4, 1, 0, 0}
      ]
  """
  def parse_input_samples(lines) when is_list(lines) do
    Stream.cycle([true])
    |> Enum.reduce_while({lines, [], [], :sample}, fn (_t, {lines, samples, opcodes, mode}) ->
      cond do
        lines == [] ->
          {:halt, {samples, Enum.reverse(opcodes)}}
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

  ## Examples

  iex> [{opnum, matches}] = Machine.Executor.find_opcode_matches([
  ...>   {{3, 2, 1, 1}, {9, 2, 1, 2}, {3, 2, 2, 1}},
  ...> ])
  iex> opnum
  9
  iex> matches
  #MapSet<[:addi, :mulr, :seti]>

  iex> [{opnum, matches}] = Machine.Executor.find_opcode_matches([
  ...>   {{3, 2, 1, 1}, {9, 2, 1, 2}, {3, 2, 2, 1}},
  ...> ], exclude: MapSet.new([:mulr]))
  iex> opnum
  9
  iex> matches
  #MapSet<[:addi, :seti]>
  """
  def find_opcode_matches(samples, opts \\ []) do
    Enum.map(samples, fn ({b4_reg, {opnum, a, b, c}, af_reg}) ->
      matches =
        @opnames
        |> Enum.reduce(MapSet.new(), fn (opname, matches) ->
          cond do
            opts[:exclude] && MapSet.member?(opts[:exclude], opname) ->
              matches
            Machine.CPU.execute(mapreg(b4_reg), {opname, a, b, c}) == mapreg(af_reg) ->
              MapSet.put(matches, opname)
            true ->
              matches
          end
        end)
      {opnum, matches}
    end)
  end

  defp mapreg(sample_reg) do
    new(4, [
      elem(sample_reg, 0),
      elem(sample_reg, 1),
      elem(sample_reg, 2),
      elem(sample_reg, 3),
    ])
  end

  @doc """
  Determine opcode names from numeric values, given a set
  of samples.
  """
  def determine_opcode_names(samples) do
    1..16
    |> Enum.reduce_while({MapSet.new(), %{}}, fn (_t, {used_names, found_nums}) ->
      lone_matches =
        find_opcode_matches(samples, exclude: used_names)
        |> Enum.filter(fn ({_opnum, matches}) -> Enum.count(matches) == 1 end)
        |> Enum.uniq()
      {used_names, found_nums} =
        lone_matches
        |> Enum.reduce({used_names, found_nums}, fn ({opnum, matches}, {used_names, found_nums}) ->
          opname = List.first(MapSet.to_list(matches))
          {MapSet.put(used_names, opname), Map.put(found_nums, opnum, opname)}
        end)
      if Enum.count(used_names) == Enum.count(@opnames) do
        {:halt, {used_names, found_nums}}
      else
        {:cont, {used_names, found_nums}}
      end
    end)
    |> elem(1)
  end
end
