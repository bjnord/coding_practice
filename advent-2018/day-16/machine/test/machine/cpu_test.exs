defmodule Machine.CPUTest do
  use ExUnit.Case
  doctest Machine.CPU

  import Machine.CPU

  #- `addr` (add register) stores into register `C` the result of adding register `A` and register `B`.
  #- `addi` (add immediate) stores into register `C` the result of adding register `A` and value `B`.
  test "add" do
    reg = %{0 => 2, 1 => 3, 2 => 1, 3 => 1}
    reg = execute(reg, {:addr, 0, 1, 2})
    assert reg == %{0 => 2, 1 => 3, 2 => 5, 3 => 1}
    reg = execute(reg, {:addi, 1, 4, 3})
    assert reg == %{0 => 2, 1 => 3, 2 => 5, 3 => 7}
    reg = execute(reg, {:addi, 2, 1, 2})
    assert reg == %{0 => 2, 1 => 3, 2 => 6, 3 => 7}
  end

  #- `mulr` (multiply register) stores into register `C` the result of multiplying register `A` and register `B`.
  #- `muli` (multiply immediate) stores into register `C` the result of multiplying register `A` and value `B`.
  test "multiply" do
    reg = %{0 => 7, 1 => 2, 2 => 11, 3 => 8}
    reg = execute(reg, {:mulr, 2, 1, 0})
    assert reg == %{0 => 22, 1 => 2, 2 => 11, 3 => 8}
    reg = execute(reg, {:muli, 1, 3, 2})
    assert reg == %{0 => 22, 1 => 2, 2 => 6, 3 => 8}
    reg = execute(reg, {:muli, 3, 7, 3})
    assert reg == %{0 => 22, 1 => 2, 2 => 6, 3 => 56}
  end

  #- `banr` (bitwise AND register) stores into register `C` the result of the bitwise AND of register `A` and register `B`.
  #- `bani` (bitwise AND immediate) stores into register `C` the result of the bitwise AND of register `A` and value `B`.
  test "binary AND" do
    reg = %{0 => 7, 1 => 14, 2 => 11, 3 => 8}
    reg = execute(reg, {:banr, 2, 1, 0})
    assert reg == %{0 => 10, 1 => 14, 2 => 11, 3 => 8}
    reg = execute(reg, {:bani, 0, 7, 3})
    assert reg == %{0 => 10, 1 => 14, 2 => 11, 3 => 2}
  end

  #- `borr` (bitwise OR register) stores into register `C` the result of the bitwise OR of register `A` and register `B`.
  #- `bori` (bitwise OR immediate) stores into register `C` the result of the bitwise OR of register `A` and value `B`.
  test "binary OR" do
    reg = %{0 => 3, 1 => 4, 2 => 9, 3 => 27}
    reg = execute(reg, {:borr, 2, 1, 0})
    assert reg == %{0 => 13, 1 => 4, 2 => 9, 3 => 27}
    reg = execute(reg, {:bori, 0, 7, 3})
    assert reg == %{0 => 13, 1 => 4, 2 => 9, 3 => 15}
  end

  #- `setr` (set register) copies the contents of register `A` into register `C`. (Input `B` is ignored.)
  #- `seti` (set immediate) stores value `A` into register `C`. (Input `B` is ignored.)
  test "set" do
    reg = %{0 => 21, 1 => 11, 2 => 7, 3 => 0}
    reg = execute(reg, {:setr, 2, 66, 0})
    assert reg == %{0 => 7, 1 => 11, 2 => 7, 3 => 0}
    reg = execute(reg, {:seti, 21, 77, 2})
    assert reg == %{0 => 7, 1 => 11, 2 => 21, 3 => 0}
  end

  #- `gtir` (greater-than immediate/register) sets register `C` to `1` if value `A` is greater than register `B`. Otherwise, register `C` is set to `0`.
  #- `gtri` (greater-than register/immediate) sets register `C` to `1` if register `A` is greater than value `B`. Otherwise, register `C` is set to `0`.
  #- `gtrr` (greater-than register/register) sets register `C` to `1` if register `A` is greater than register `B`. Otherwise, register `C` is set to `0`.
  test "greater than" do
    reg = %{0 => 2, 1 => 4, 2 => 6, 3 => 8}
    reg = execute(reg, {:gtir, 1, 0, 3})
    assert reg == %{0 => 2, 1 => 4, 2 => 6, 3 => 0}
    reg = execute(reg, {:gtir, 3, 0, 3})
    assert reg == %{0 => 2, 1 => 4, 2 => 6, 3 => 1}
    reg = execute(reg, {:gtri, 1, 3, 2})
    assert reg == %{0 => 2, 1 => 4, 2 => 1, 3 => 1}
    reg = execute(reg, {:gtri, 1, 4, 2})
    assert reg == %{0 => 2, 1 => 4, 2 => 0, 3 => 1}
    reg = execute(reg, {:gtrr, 0, 1, 2})
    assert reg == %{0 => 2, 1 => 4, 2 => 0, 3 => 1}
    reg = execute(reg, {:gtrr, 1, 0, 2})
    assert reg == %{0 => 2, 1 => 4, 2 => 1, 3 => 1}
  end

  #- `eqir` (equal immediate/register) sets register `C` to `1` if value `A` is equal to register `B`. Otherwise, register `C` is set to `0`.
  #- `eqri` (equal register/immediate) sets register `C` to `1` if register `A` is equal to value `B`. Otherwise, register `C` is set to `0`.
  #- `eqrr` (equal register/register) sets register `C` to `1` if register `A` is equal to register `B`. Otherwise, register `C` is set to `0`.
  test "equal to" do
    reg = %{0 => 2, 1 => 4, 2 => 6, 3 => 8}
    reg = execute(reg, {:eqir, 1, 0, 3})
    assert reg == %{0 => 2, 1 => 4, 2 => 6, 3 => 0}
    reg = execute(reg, {:eqir, 0, 3, 3})
    assert reg == %{0 => 2, 1 => 4, 2 => 6, 3 => 1}
    reg = execute(reg, {:eqri, 1, 4, 2})
    assert reg == %{0 => 2, 1 => 4, 2 => 1, 3 => 1}
    reg = execute(reg, {:eqri, 1, 5, 2})
    assert reg == %{0 => 2, 1 => 4, 2 => 0, 3 => 1}
    reg = execute(reg, {:eqrr, 0, 1, 3})
    assert reg == %{0 => 2, 1 => 4, 2 => 0, 3 => 0}
    reg = execute(reg, {:eqrr, 2, 3, 0})
    assert reg == %{0 => 1, 1 => 4, 2 => 0, 3 => 0}
  end
end
