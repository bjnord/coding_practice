defmodule Potions do
  @moduledoc """
  Documentation for `Potions`.
  """

  @doc """
  Calculate number of potions required for a sequence of battles (using
  part 1 rules).

  ## Examples

      iex> Potions.calc_p1("ABC")
      4

  """
  def calc_p1(creatures) do
    to_charlist(creatures)
    |> Enum.map(&battle_potions/1)
    |> Enum.sum()
  end

  defp battle_potions(c) do
    case c do
      ?A -> 0
      ?B -> 1
      ?C -> 3
      ?D -> 5
      _  -> raise "unknown creature #{c}"
    end
  end

  @doc """
  Calculate number of potions required for a sequence of battles (using
  part 2 rules).

  ## Examples

      iex> Potions.calc_p2("ABCD")
      13

  """
  def calc_p2(creatures) do
    to_charlist(creatures)
    |> Enum.chunk_every(2)
    |> Enum.map(&pair_strength/1)
    |> Enum.sum()
  end

  def pair_strength([?x, ?x]), do: 0
  def pair_strength([m, ?x]), do: battle_potions(m)
  def pair_strength([?x, m]), do: battle_potions(m)
  def pair_strength([m1, m2]) do
    battle_potions(m1) + 1 + battle_potions(m2) + 1
  end

  def main(argv) do
    [p1_file | [p2_file | _]] = argv
    potions = p1_file
              |> File.read!()
              |> calc_p1()
    IO.puts("Part 1: #{potions} potions")
    potions = p2_file
              |> File.read!()
              |> calc_p2()
    IO.puts("Part 2: #{potions} potions")
  end
end
