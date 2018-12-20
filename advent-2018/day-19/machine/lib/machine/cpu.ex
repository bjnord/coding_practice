defmodule Machine.CPU do
  @moduledoc """
  CPU behavior for `Machine`.
  """

  import Machine.Register
  use Bitwise

  @doc """
  Execute an instruction.
  """
  def execute(reg, {opname, a, b, c}) do
    case opname do
      #- `addr` (add register) stores into register `C` the result of adding register `A` and register `B`.
      :addr ->
        set(reg, c, reg[a] + reg[b])
      #- `addi` (add immediate) stores into register `C` the result of adding register `A` and value `B`.
      :addi ->
        set(reg, c, reg[a] + b)
      #- `mulr` (multiply register) stores into register `C` the result of multiplying register `A` and register `B`.
      :mulr ->
        set(reg, c, reg[a] * reg[b])
      #- `muli` (multiply immediate) stores into register `C` the result of multiplying register `A` and value `B`.
      :muli ->
        set(reg, c, reg[a] * b)
      #- `banr` (bitwise AND register) stores into register `C` the result of the bitwise AND of register `A` and register `B`.
      :banr ->
        set(reg, c, Bitwise.band(reg[a], reg[b]))
      #- `bani` (bitwise AND immediate) stores into register `C` the result of the bitwise AND of register `A` and value `B`.
      :bani ->
        set(reg, c, Bitwise.band(reg[a], b))
      #- `borr` (bitwise OR register) stores into register `C` the result of the bitwise OR of register `A` and register `B`.
      :borr ->
        set(reg, c, Bitwise.bor(reg[a], reg[b]))
      #- `bori` (bitwise OR immediate) stores into register `C` the result of the bitwise OR of register `A` and value `B`.
      :bori ->
        set(reg, c, Bitwise.bor(reg[a], b))
      #- `setr` (set register) copies the contents of register `A` into register `C`. (Input `B` is ignored.)
      :setr ->
        set(reg, c, reg[a])
      #- `seti` (set immediate) stores value `A` into register `C`. (Input `B` is ignored.)
      :seti ->
        set(reg, c, a)
      #- `gtir` (greater-than immediate/register) sets register `C` to `1` if value `A` is greater than register `B`. Otherwise, register `C` is set to `0`.
      :gtir ->
        flag = if a > reg[b], do: 1, else: 0
        set(reg, c, flag)
      #- `gtri` (greater-than register/immediate) sets register `C` to `1` if register `A` is greater than value `B`. Otherwise, register `C` is set to `0`.
      :gtri ->
        flag = if reg[a] > b, do: 1, else: 0
        set(reg, c, flag)
      #- `gtrr` (greater-than register/register) sets register `C` to `1` if register `A` is greater than register `B`. Otherwise, register `C` is set to `0`.
      :gtrr ->
        flag = if reg[a] > reg[b], do: 1, else: 0
        set(reg, c, flag)
      #- `eqir` (equal immediate/register) sets register `C` to `1` if value `A` is equal to register `B`. Otherwise, register `C` is set to `0`.
      :eqir ->
        flag = if a == reg[b], do: 1, else: 0
        set(reg, c, flag)
      #- `eqri` (equal register/immediate) sets register `C` to `1` if register `A` is equal to value `B`. Otherwise, register `C` is set to `0`.
      :eqri ->
        flag = if reg[a] == b, do: 1, else: 0
        set(reg, c, flag)
      #- `eqrr` (equal register/register) sets register `C` to `1` if register `A` is equal to register `B`. Otherwise, register `C` is set to `0`.
      :eqrr ->
        flag = if reg[a] == reg[b], do: 1, else: 0
        set(reg, c, flag)
    end
  end

  defp op_reg(opatom) do
    case opatom do
      :addr -> [:a, :b, :c]
      :addi -> [:a, :c]
      :mulr -> [:a, :b, :c]
      :muli -> [:a, :c]
      :banr -> [:a, :b, :c]
      :bani -> [:a, :c]
      :borr -> [:a, :b, :c]
      :bori -> [:a, :c]
      :setr -> [:a, :c]
      :seti -> [:c]
      :gtir -> [:b, :c]
      :gtri -> [:a, :c]
      :gtrr -> [:a, :b, :c]
      :eqir -> [:b, :c]
      :eqri -> [:a, :c]
      :eqrr -> [:a, :b, :c]
    end
  end

  defp op_b_ignored(opatom) do
    case opatom do
      :setr -> true
      :seti -> true
      _ -> false
    end
  end

  @doc """
  Run a program.

  ## Returns

  Program registers at end of program
  """
  def run_program(program, opts \\ []) do
    ###
    # "The instruction pointer starts at 0."
    initial_ip = 0
    initial_r0 = if opts[:initial_r0], do: opts[:initial_r0], else: 0
    initial_reg = new(6)
                |> set(:ip, program[:ip])
                |> set(0, initial_r0)
    if opts[:show_reg] do
      IO.inspect({initial_ip, initial_reg}, label: "initial IP,registers")
    end
    Stream.cycle([true])
    |> Enum.reduce_while({initial_ip, initial_reg}, fn (_t, {ip, reg}) ->
      #if opts[:show_reg] do
      #  IO.inspect({ip, reg}, label: "IP,registers before execute()")
      #end
      ###
      # "When the instruction pointer is bound to a register, its value is
      # written to that register just before each instruction is executed,"
      reg =
        if reg[:ip] do
          #IO.inspect(ip, label: "IP written to R#{reg[:ip]}")
          Map.replace!(reg, reg[:ip], ip)
        else
          reg
        end
      ###
      # "If the instruction pointer ever causes the device to attempt to
      # load an instruction outside the instructions defined in the program,
      # the program instead immediately halts."
      if program[ip] do
        ###
        # execute the instruction at IP
        #IO.inspect(program[ip], label: "execute opcode")
        reg = execute(reg, program[ip])
        #IO.inspect({ip, reg}, label: "IP,registers after execute()")
        ###
        # "the value of that register is written back to the instruction
        # pointer immediately after each instruction finishes execution."
        #
        # "Afterward, move to the next instruction by adding one to the
        # instruction pointer, even if the value in the instruction pointer
        # was just updated by an instruction."
        ip =
          if reg[:ip] do
            (reg[reg[:ip]] + 1)
            #|> IO.inspect(label: "IP read from R#{reg[:ip]} and incremented")
          else
            (ip + 1)
            #|> IO.inspect(label: "IP incremented")
          end
        if opts[:show_reg] do
          IO.inspect({ip, reg}, label: "new IP,registers")
        end
        {:cont, {ip, reg}}
      else
        #IO.inspect(ip, label: "no instruction at IP (halt)")
        {:halt, {ip, reg}}
      end
    end)
    |> elem(1)
  end

  @doc """
  Disassemble a program.

  ## Returns

  Lines of disassembly output
  """
  def disassemble_program(program) do
    0..i_count(program)
    |> Enum.reduce([], fn (i, lines) ->
      [disassemble_opcode(program, i) | lines]
    end)
    |> Enum.reverse
  end

  defp i_count(program) do
    program
    |> Enum.filter(fn ({k, _v}) -> is_integer(k) end)
    |> Enum.max_by(fn ({k, _v}) -> k end)
    |> elem(0)
  end

  defp disassemble_opcode(program, i) when is_integer(i) do
    {opatom, a, b, c} = program[i]
    if jmp?(opatom) && (c == program[:ip]) do
      disassemble_jmp(i, opatom, a, b)
    else
      format_opcode(i, opatom, a, b, c)
    end
  end

  defp format_opcode(i, opatom, a, b, c) do
    {i, opname} = format_i_op(i, opatom)
    {a, b, c} = format_reg(opatom, a, b, c)
    if op_b_ignored(opatom) do
      "#{i} #{opname} #{a} #{c}"
    else
      "#{i} #{opname} #{a} #{b} #{c}"
    end
  end

  defp format_i_op(i, opatom) do
    i = Integer.to_string(i)
        |> String.pad_leading(6, "0")
    opname = Atom.to_string(opatom)
             |> String.upcase
    {i, opname}
  end

  defp format_reg(opatom, a, b, c) do
    a = "#{to_reg(opatom, a, :a)}"
    b = "#{to_reg(opatom, b, :b)}"
    c = "#{to_reg(opatom, c, :c)}"
    {a, b, c}
  end

  defp to_reg(opatom, v, vkey) do
    if vkey in op_reg(opatom), do: "R#{v}", else: "#{v}"
  end

  ###
  # JMPx/JMRx are pseudo-instructions; they're a helpful way to visualize
  # SETx/ADDx for the register bound to the IP
  #
  # so we keep these functions separate from the real ones
  ###

  defp disassemble_jmp(i, opatom, a, b) do
    case opatom do
      :setr ->
        format_jmp(i, :jmpr, a)
      :seti ->
        format_jmp(i, :jmpi, a)
      :addr ->
        format_jmp(i, :jmrr, a, b)
      :addi ->
        format_jmp(i, :jmri, a, b)
    end
  end

  defp format_jmp(i, opatom, a, b \\ nil) do
    {i, opname} = format_i_op(i, opatom)
    if b do
      {a, b} = format_reg(opatom, a, b)
      "#{i} #{opname} #{a} #{b}"
    else
      a = format_reg(opatom, a)
      "#{i} #{opname} #{a}"
    end
  end

  defp format_reg(opatom, a, b) do
    a = format_reg(opatom, a)
    b = "#{to_jmp_reg(opatom, b, :b)}"
    {a, b}
  end

  defp format_reg(opatom, a) do
    "#{to_jmp_reg(opatom, a, :a)}"
  end

  defp to_jmp_reg(opatom, v, vkey) do
    if vkey in jmp_reg(opatom), do: "R#{v}", else: "#{v}"
  end

  defp jmp_reg(opatom) do
    case opatom do
      :jmrr -> [:a, :b]
      :jmri -> [:a]
      :jmpr -> [:a]
      :jmpi -> []
    end
  end

  defp jmp?(opatom) do
    opatom in [:addr, :addi, :setr, :seti]
  end
end
