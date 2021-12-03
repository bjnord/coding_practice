defmodule Depth do
  @moduledoc """
  Documentation for Depth.
  """

  @doc """
  Solve part 1.
  """
  def part1([filename]) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&String.to_integer/1)
    |> count_increases
    |> IO.inspect(label: "Part 1 number of increases is")
  end

  @doc """
  Count the number of depth measurement increases.

  Returns the number of increases.

  ## Examples
      iex> Depth.count_increases([-5, -3, -8, 0, 1, 2, -1, 7, 0])
      5
      iex> Depth.count_increases([199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
      7
  """
  def count_increases(depths) do
    # implementation by José Valim
    depths
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.count(fn [left, right] -> right > left end)
  end

  @doc """
  Solve part 2.
  """
  def part2([filename]) do
    File.stream!(filename)
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&String.to_integer/1)
    |> sliding_windows_of(3)
    |> count_increases
    |> IO.inspect(label: "Part 2 number of sliding-window increases is")
  end

  defp sliding_windows_of(depths, n) do
    depths
    |> Stream.chunk_every(n, 1, :discard)
    |> Stream.map(&Enum.sum/1)
  end
end
