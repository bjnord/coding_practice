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
  def run_program(program) do
    reg = new(4)
    program
    |> Enum.reduce(reg, fn (opset, reg) ->
      execute(reg, opset)
    end)
  end
end
