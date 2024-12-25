defmodule Lock do
  @moduledoc """
  Documentation for `Lock`.
  """

  import Bitwise
  import Lock.Parser
  require Logger
  import History.CLI

  def fits(objects, n_slots \\ 5, max_height \\ 7) do
    {locks, keys} = locks_and_keys(objects, max_height)
    locks
    |> Enum.reduce(0, fn lock, acc ->
      keys
      |> Enum.reduce(acc, fn key, acc ->
        debug(lock, key, n_slots * max_height)
        if (lock &&& key) == 0b0 do
          acc + 1
        else
          acc
        end
      end)
    end)
  end

  defp debug(lock, key, bwidth) do
    Logger.debug("")
    Logger.debug("lock: #{debug_bin(lock, bwidth)}")
    Logger.debug("key:  #{debug_bin(key, bwidth)}")
    Logger.debug("AND:  #{debug_bin((lock &&& key), bwidth)}")
  end

  defp debug_bin(b, bwidth) do
    Integer.to_string(b, 2)
    |> String.pad_leading(bwidth, "0")
  end

  defp locks_and_keys(objects, max_height) do
    locks =
      objects
      |> Enum.filter(&(elem(&1, 0) == :lock))
      |> Enum.map(&(bitmap_of_object(&1, max_height)))
    keys =
      objects
      |> Enum.filter(&(elem(&1, 0) == :key))
      |> Enum.map(&(bitmap_of_object(&1, max_height)))
    {locks, keys}
  end

  def bitmap_of_object({_obj_type, pairs} = _object, max_height) do
    bitmap_concat(pairs, max_height)
  end

  def bitmap_concat(pairs, max_height) do
    pairs
    |> Enum.reduce(0b0, fn {_height, bitmap}, acc ->
      acc * (2 ** max_height) + bitmap
    end)
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
    |> Lock.fits()
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
end
