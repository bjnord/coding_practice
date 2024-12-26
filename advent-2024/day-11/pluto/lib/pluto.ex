defmodule Pluto do
  @moduledoc """
  Documentation for `Pluto`.
  """

  import Pluto.Parser
  import History.CLI

  def blink(stone_map) do
    stone_map
    |> Enum.reduce(stone_map, fn {stone, count}, stone_map ->
      map_transform(stone_map, stone, count)
    end)
  end

  # update a stone map by
  # - subtracting `count` of `stone` from the map
  # - transforming `stone` to new list of stones
  # - updating the resulting new stones' counts in the map
  defp map_transform(stone_map, stone, count) do
    stone_map
    |> reduce_count(stone, count)
    |> update_counts(transform(stone), count)
  end

  defp reduce_count(stone_map, stone, count) do
    Map.get_and_update(stone_map, stone, fn cur ->
      if cur == count do
        :pop
      else
        {cur, cur - count}
      end
    end)
    |> elem(1)
  end

  defp update_counts(stone_map, stones, count) do
    stones
    |> Enum.reduce(stone_map, fn stone, acc ->
      Map.update(acc, stone, count, &(&1 + count))
    end)
  end

  # transform a stone into a **list** of new stones that **replaces** it
  defp transform(stone) do
    cond do
      # "If the stone is engraved with the number 0, it is replaced by a
      # stone engraved with the number 1."
      stone == 0 ->
        [1]
      # "If the stone is engraved with a number that has an even number
      # of digits, it is replaced by two stones. The left half of the
      # digits are engraved on the new left stone, and the right half of
      # the digits are engraved on the new right stone. (The new numbers
      # don't keep extra leading zeroes: 1000 would become stones 10 and
      # 0.)"
      rem(String.length(Integer.to_string(stone)), 2) == 0 ->
        divide(stone)
      # "If none of the other rules apply, the stone is replaced by a new
      # stone; the old stone's number multiplied by 2024 is engraved on
      # the new stone."
      true ->
        [stone * 2024]
    end
  end

  @doc """
  Divide a stone in half.

  ## Examples
      iex> divide(98)
      [9, 8]
      iex> divide(901257)
      [901, 257]
  """
  def divide(stone) do
    stone_s = Integer.to_string(stone)
    length = String.length(stone_s)
    half_length = div(length, 2)
    a = String.slice(stone_s, 0..(half_length - 1))
    b = String.slice(stone_s, half_length..(length - 1))
    [a, b]
    |> Enum.map(&String.to_integer/1)
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
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Pluto.n_stones(25)
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Pluto.dp_n_stones(75)
    |> IO.inspect(label: "Part 2 answer is")
  end
end
