defmodule Computer do
  @moduledoc """
  Documentation for `Computer`.
  """

  import Bitwise
  import Computer.Parser
  import History.CLI

  @type registers() :: {integer(), integer(), integer()}
  @type program() :: %{integer() => integer()}

  @spec run({registers(), program()}) :: {registers(), [integer()]}
  def run({registers, program}) do
    {registers, outputs} =
      exec({registers, program}, 0, [], next_ops(program, 0))
    {registers, Enum.reverse(outputs)}
  end

  @spec run_using_a({registers(), program()}, integer()) :: {registers(), [integer()]}
  def run_using_a({{_, b, c}, program}, a), do: run({{a, b, c}, program})

  def output_string({_registers, outputs}) do
    Enum.join(outputs, ",")
  end

  defp next_ops(program, pc) do
    if Map.get(program, pc) == nil do
      []
    else
      Map.take(program, [pc, pc+1])
      |> Map.to_list()
      |> Enum.sort()
      |> Enum.map(fn {_k, v} -> v end)
    end
  end

  # If the computer tries to read an opcode past the end of the program, it instead halts.
  defp exec({registers, _program}, _pc, output, []), do: {registers, output}
  defp exec({registers, program}, pc, output, [op1, op2]) when op1 == 3 do
    new_pc = jnz({registers, pc}, op1, op2)
    exec({registers, program}, new_pc, output, next_ops(program, new_pc))
  end
  defp exec({registers, program}, pc, output, [op1, op2]) do
    {registers, output} =
      case op1 do
        0 -> adv({registers, output}, op1, op2)
        1 -> bxl({registers, output}, op1, op2)
        2 -> bst({registers, output}, op1, op2)
        4 -> bxc({registers, output}, op1, op2)
        5 -> out({registers, output}, op1, op2)
        6 -> bdv({registers, output}, op1, op2)
        7 -> cdv({registers, output}, op1, op2)
      end
    exec({registers, program}, pc + 2, output, next_ops(program, pc + 2))
  end

  @doc """
  The value of a combo operand can be found as follows:

  - Combo operands 0 through 3 represent literal values 0 through 3.
  - Combo operand 4 represents the value of register A.
  - Combo operand 5 represents the value of register B.
  - Combo operand 6 represents the value of register C.
  - Combo operand 7 is reserved and will not appear in valid programs.
  """
  def combo({a, b, c}, op) do
    cond do
      op >= 0 && op <= 3 -> op
      op == 4            -> a
      op == 5            -> b
      op == 6            -> c
    end
  end

  @doc """
  The `adv` instruction (opcode `0`) performs **division**. The numerator
  is the value in the `A` register. The denominator is found by raising
  2 to the power of the instruction's **combo** operand. (So, an operand
  of `2` would divide `A` by `4` (`2^2`); an operand of `5` would divide
  `A` by `2^B`.) The result of the division operation is **truncated**
  to an integer and then written to the `A` register.
  """
  def adv({{a, b, c}, output}, _op1, op2) do
    a = register_a_div({a, b, c}, op2)
    {{a, b, c}, output}
  end

  defp register_a_div({a, b, c}, op2) do
    num = a
    den = 2 ** combo({a, b, c}, op2)
    div(num, den)
  end

  @doc """
  The `bxl` instruction (opcode `1`) calculates the
  [bitwise XOR](https://en.wikipedia.org/wiki/Bitwise_operation#XOR)
  of register `B` and the instruction's **literal** operand, then stores
  the result in register `B`.
  """
  def bxl({{a, b, c}, output}, _op1, op2) do
    b = bxor(b, op2)
    {{a, b, c}, output}
  end

  @doc """
  The `bst` instruction (opcode `2`) calculates the value of its
  **combo** operand
  [modulo](https://en.wikipedia.org/wiki/Modulo)
  8 (thereby keeping only its lowest 3 bits), then writes that value to
  the `B` register.
  """
  def bst({{a, b, c}, output}, _op1, op2) do
    b = rem(combo({a, b, c}, op2), 8)
    {{a, b, c}, output}
  end

  @doc """
  The `jnz` instruction (opcode `3`) does **nothing** if the `A` register
  is `0`. However, if the `A` register is **not zero**, it **jumps**\*
  by setting the instruction pointer to the value of its **literal**
  operand; if this instruction jumps, the instruction pointer is **not**
  increased by `2` after this instruction.

  \* The instruction does this using a little trampoline.
  """
  def jnz({{a, _b, _c}, pc}, _op1, op2) do
    cond do
      a == 0 -> pc + 2
      true   -> op2
    end
  end

  @doc """
  The `bxc` instruction (opcode `4`) calculates the **bitwise XOR**
  of register `B` and register `C`, then stores the result in register
  `B`. (For legacy reasons, this instruction reads an operand but
  **ignores** it.)
  """
  def bxc({{a, b, c}, output}, _op1, _op2) do
    b = bxor(b, c)
    {{a, b, c}, output}
  end

  @doc """
  The `out` instruction (opcode `5`) calculates the value of its **combo**
  operand modulo 8, then **outputs** that value. (If a program outputs
  multiple values, they are separated by commas.)
  """
  def out({{a, b, c}, output}, _op1, op2) do
    out = rem(combo({a, b, c}, op2), 8)
    {{a, b, c}, [out | output]}
  end

  @doc """
  The `bdv` instruction (opcode `6`) works exactly like the
  `adv` instruction except that the result is stored in the **`B`
  register**. (The numerator is still read from the `A` register.)
  """
  def bdv({{a, b, c}, output}, _op1, op2) do
    b = register_a_div({a, b, c}, op2)
    {{a, b, c}, output}
  end

  @doc """
  The `cdv` instruction (opcode `7`) works exactly like the
  `adv` instruction except that the result is stored in the **`C`
  register**. (The numerator is still read from the `A` register.)
  """
  def cdv({{a, b, c}, output}, _op1, op2) do
    c = register_a_div({a, b, c}, op2)
    {{a, b, c}, output}
  end

  @spec disassemble({registers(), program()}) :: [String.t()]
  def disassemble({_registers, program}) do
    program
    |> Enum.chunk_every(2)
    |> Enum.sort()
    |> Enum.map(fn [{_k1, v1}, {_k2, v2}] -> {v1, v2} end)
    |> Enum.map(fn {op1, op2} -> disassemble(op1, op2) end)
  end

  defp disassemble(0, op2), do: combo_op_to_string(0, "A", op2)  # ADV
  defp disassemble(1, op2), do: literal_to_string(1, op2)        # BXL
  defp disassemble(2, op2), do: combo_to_string(2, op2)          # BST
  defp disassemble(3, op2), do: literal_to_string(3, op2)        # JNZ
  defp disassemble(4, op2), do: fixed_to_string(4, "C", op2)     # BXC
  defp disassemble(5, op2), do: combo_to_string(5, op2)          # OUT
  defp disassemble(6, op2), do: combo_op_to_string(6, "A", op2)  # BDV
  defp disassemble(7, op2), do: combo_op_to_string(7, "A", op2)  # CDV

  defp combo_to_string(op1, op2) do
    "#{op1} #{op2} :: #{opcode_of(op1)} #{combo_operand(op2)}"
  end
  defp combo_op_to_string(op1, xop, op2) do
    "#{op1} #{op2} :: #{opcode_of(op1)} #{xop}, #{combo_operand(op2)}"
  end
  defp literal_to_string(op1, op2) do
    "#{op1} #{op2} :: #{opcode_of(op1)} ##{op2}"
  end
  defp fixed_to_string(op1, xop, op2) do
    "#{op1} #{op2} :: #{opcode_of(op1)} #{xop}"
  end
  def combo_operand(op2) do
    cond do
      op2 >= 0 && op2 <= 3 -> "##{op2}"
      op2 == 4             -> "A"
      op2 == 5             -> "B"
      op2 == 6             -> "C"
    end
  end

  def opcode_of(op1) do
    case op1 do
      0 -> "ADV"
      1 -> "BXL"
      2 -> "BST"
      3 -> "JNZ"
      4 -> "BXC"
      5 -> "OUT"
      6 -> "BDV"
      7 -> "CDV"
    end
  end

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
    if opts[:verbose], do: print_disassembly(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Computer.run()
    |> Computer.output_string()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Process input file and print a disassembly of the program.
  """
  def print_disassembly(input_path) do
    parse_input_file(input_path)
    |> Computer.disassemble()
    |> Enum.map(&IO.puts/1)
  end
end
