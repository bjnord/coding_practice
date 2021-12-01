defmodule Depth do
  @moduledoc """
  Documentation for Depth.
  """

  @doc """
  Solve part 1.
  """
  def part1([filename]) do
    depths = filename
    |> File.read!
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    count_increases(depths)
    |> IO.inspect(label: "Part 1 number of increases is")
  end

  def count_increases(list), do: count_increases(0, list)
  def count_increases(n, [_]), do: n
  def count_increases(n, [head | tail]) do
    [middle | _] = tail
    n = if middle > head, do: n + 1, else: n
    count_increases(n, tail)
  end
end
