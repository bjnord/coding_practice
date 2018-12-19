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

  @doc """
  Run a program.

  ## Returns

  Program registers at end of program
  """
  def run_program(program, initial_r0 \\ 0) do
    ###
    # "The instruction pointer starts at 0."
    initial_ip = 0
    initial_reg = new(6)
                |> set(:ip, program[:ip])
                |> set(0, initial_r0)
    Stream.cycle([true])
    |> Enum.reduce_while({initial_ip, initial_reg}, fn (_t, {ip, reg}) ->
      #IO.inspect({ip, reg}, label: "registers @ end")
      ###
      # "When the instruction pointer is bound to a register, its value is
      # written to that register just before each instruction is executed,"
      reg = if reg[:ip], do: Map.replace!(reg, reg[:ip], ip), else: reg
      ###
      # "If the instruction pointer ever causes the device to attempt to
      # load an instruction outside the instructions defined in the program,
      # the program instead immediately halts."
      if program[ip] do
        ###
        # execute the instruction at IP
        #IO.inspect(program[ip], label: "execute opcode")
        reg = execute(reg, program[ip])
        #IO.inspect({ip, reg}, label: "registers @ middle")
        ###
        # "the value of that register is written back to the instruction
        # pointer immediately after each instruction finishes execution."
        #
        # "Afterward, move to the next instruction by adding one to the
        # instruction pointer, even if the value in the instruction pointer
        # was just updated by an instruction."
        ip = if reg[:ip], do: reg[reg[:ip]] + 1, else: ip + 1
        #IO.inspect({ip, reg}, label: "registers @ end")
        {:cont, {ip, reg}}
      else
        {:halt, {ip, reg}}
      end
    end)
    |> elem(1)
  end
end
