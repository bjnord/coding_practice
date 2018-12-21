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
      dump_reg(initial_reg, opts ++ [ip: initial_ip])
      IO.puts("")
    end
    Stream.cycle([true])
    |> Enum.reduce_while({initial_ip, initial_reg}, fn (_t, {ip, reg}) ->
      ###
      # "When the instruction pointer is bound to a register, its value is
      # written to that register just before each instruction is executed,"
      reg = ip_to_bound(reg, ip, opts)
      ###
      # "If the instruction pointer ever causes the device to attempt to
      # load an instruction outside the instructions defined in the program,
      # the program instead immediately halts."
      if program[ip] do
        ###
        # execute the instruction at IP
        if opts[:show_reg] do
          # 7 spaces is width of "IP(Rx):" label
          IO.puts("       " <> disassemble_opcode(program, ip, opts))
        end
        reg = execute(reg, program[ip])
              |> incr_icount()
        ###
        # "the value of that register is written back to the instruction
        # pointer immediately after each instruction finishes execution."
        #
        # "Afterward, move to the next instruction by adding one to the
        # instruction pointer, even if the value in the instruction pointer
        # was just updated by an instruction."
        ip = bound_to_ip(reg, ip) + 1
        if opts[:show_reg] do
          dump_reg(reg, opts ++ [ip: ip])
          IO.puts("")
        end
        {:cont, {ip, reg}}
      else
        #IO.inspect(ip, label: "no instruction at IP (halt)")
        {:halt, {ip, reg}}
      end
    end)
    |> elem(1)
  end

  defp ip_to_bound(reg, ip, opts) do
    cond do
      reg[:ip] && opts[:show_reg] ->
        Map.replace!(reg, reg[:ip], ip)
        |> dump_bound_ip_reg(opts)
      reg[:ip] ->
        Map.replace!(reg, reg[:ip], ip)
      true ->
        reg
    end
  end

  defp bound_to_ip(reg, ip) do
    if reg[:ip], do: reg[reg[:ip]], else: ip
  end

  defp incr_icount(reg) do
    Map.update(reg, :icount, 1, &(&1 + 1))
  end

  @doc """
  Disassemble a program.

  ## Returns

  Lines of disassembly output
  """
  def disassemble_program(program, opts \\ []) do
    0..i_count(program)
    |> Enum.reduce([], fn (i, lines) ->
      [disassemble_opcode(program, i, opts) | lines]
    end)
    |> Enum.reverse
  end

  defp i_count(program) do
    program
    |> Enum.filter(fn ({k, _v}) -> is_integer(k) end)
    |> Enum.max_by(fn ({k, _v}) -> k end)
    |> elem(0)
  end

  defp disassemble_opcode(program, i, opts) when is_integer(i) do
    {opatom, a, b, c} = program[i]
    if jmp?(opatom) && (c == program[:ip]) do
      disassemble_jmp(i, opatom, a, b, opts)
    else
      format_opcode(i, opatom, a, b, c, opts)
    end
  end

  defp format_opcode(i, opatom, a, b, c, opts) do
    {i, opname} = format_i_op(i, opatom, opts)
    {a, b, c} = format_reg(opatom, a, b, c, opts)
    if op_b_ignored(opatom) do
      "#{i} #{opname} #{a} #{c}"
    else
      "#{i} #{opname} #{a} #{b} #{c}"
    end
  end

  defp format_i_op(i, opatom, opts) do
    opname = Atom.to_string(opatom)
             |> String.upcase
    {format_i(i, opts), opname}
  end

  defp format_reg(opatom, a, b, c, opts) do
    a = to_reg(opatom, a, :a, opts)
    b = to_reg(opatom, b, :b, opts)
    c = to_reg(opatom, c, :c, opts)
    {a, b, c}
  end

  defp to_reg(opatom, v, vkey, opts) do
    if vkey in op_reg(opatom) do
      "R#{v}"
    else
      format_r(v, opts)
    end
  end

  ###
  # JMPx/JADx are pseudo-instructions; they're a helpful way to visualize
  # SETx/ADDx for the register bound to the IP
  #
  # so we keep these functions separate from the real ones
  ###

  defp disassemble_jmp(i, opatom, a, b, opts) do
    case opatom do
      :setr ->
        format_jmp(i, :jmpr, a, opts)
      :seti ->
        format_jmp(i, :jmpi, a, opts)
      :addr ->
        format_jad(i, :jadr, a, b, opts)
      :addi ->
        format_jad(i, :jadi, a, b, opts)
    end
  end

  defp format_jmp(i, opatom, a, opts) do
    {i, opname} = format_i_op(i, opatom, opts)
    a = format_jreg(opatom, a, opts)
    "#{i} #{opname} #{a}"
  end

  defp format_jad(i, opatom, a, b, opts) do
    {i, opname} = format_i_op(i, opatom, opts)
    {a, b} = format_jreg(opatom, a, b, opts)
    "#{i} #{opname} #{a} #{b}"
  end

  defp format_jreg(opatom, a, opts) do
    to_jreg(opatom, a, :a, opts)
  end

  defp format_jreg(opatom, a, b, opts) do
    a = format_jreg(opatom, a, opts)
    b = to_jreg(opatom, b, :b, opts)
    {a, b}
  end

  defp to_jreg(opatom, v, vkey, opts) do
    if vkey in jmp_reg(opatom) do
      "R#{v}"
    else
      format_r(v, opts)
    end
  end

  defp jmp_reg(opatom) do
    case opatom do
      :jadr -> [:a, :b]
      :jadi -> [:a]
      :jmpr -> [:a]
      :jmpi -> []
    end
  end

  defp jmp?(opatom) do
    opatom in [:addr, :addi, :setr, :seti]
  end
end
