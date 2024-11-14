defmodule Potions do
  @moduledoc """
  Documentation for `Potions`.
  """

  @doc """
  Calculate number of potions required for a sequence of battles.

  ## Examples

      iex> Potions.calc("ABC")
      4

  """
  def calc(battles) do
    to_charlist(battles)
    |> Enum.map(&battle_potions/1)
    |> Enum.sum()
  end

  defp battle_potions(c) do
    case c do
      ?A -> 0
      ?B -> 1
      ?C -> 3
      _  -> raise "unknown battle #{c}"
    end
  end

  def main(argv) do
    potions = File.read!(hd(argv))
              |> calc()
    IO.puts("Part 1: #{potions} potions")
  end
end
