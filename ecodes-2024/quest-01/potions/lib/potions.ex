defmodule Potions do
  @moduledoc """
  Documentation for `Potions`.
  """

  import Kingdom.CLI

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

  @doc """
  Calculate number of potions required for a sequence of battles (using
  part 3 rules).

  ## Examples

      iex> Potions.calc_p3("ABCBCD")
      25

  """
  def calc_p3(creatures) do
    to_charlist(creatures)
    |> Enum.chunk_every(3)
    |> Enum.map(&triad_strength/1)
    |> Enum.sum()
  end

  def triad_strength([?x, ?x, ?x]), do: 0
  def triad_strength([m, ?x, ?x]), do: battle_potions(m)
  def triad_strength([?x, m, ?x]), do: battle_potions(m)
  def triad_strength([?x, ?x, m]), do: battle_potions(m)
  def triad_strength([?x, m1, m2]), do: pair_strength([m1, m2])
  def triad_strength([m1, ?x, m2]), do: pair_strength([m1, m2])
  def triad_strength([m1, m2, ?x]), do: pair_strength([m1, m2])
  def triad_strength([m1, m2, m3]) do
    battle_potions(m1) + 2 + battle_potions(m2) + 2 + battle_potions(m3) + 2
  end

  def parse_input_file(part) do
    "private/everybody_codes_e2024_q01_p#{part}.txt"
    |> File.read!()
  end

  def main(argv) do
    opts = parse_args(argv)
    opts[:parts]
    |> Enum.each(fn part ->
      creatures = parse_input_file(part)
      apply(Potions, :"calc_p#{part}", [creatures])
      |> IO.inspect(label: "Part #{part}")
    end)
  end
end
