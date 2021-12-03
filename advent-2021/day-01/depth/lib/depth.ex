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
    depths = filename
    |> File.read!
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    count_sliding_increases(depths)
    |> IO.inspect(label: "Part 2 number of sliding-window increases is")
  end

  @doc """
  Count the number of 3-integer sums which are larger than the preceding 3-integer sum.

  ## Examples
      iex> Depth.count_sliding_increases([-5, -3, -8, 0, 1, 2, -1, 7, 0])
      4
      iex> Depth.count_sliding_increases([607, 618, 618, 617, 647, 716, 769, 792])
      5
  """
  def count_sliding_increases(list) do
    [a, b, c | tail] = list
    count_sliding_increases(0, [a, b, c], tail)
  end
  def count_sliding_increases(n, _window, []), do: n
  def count_sliding_increases(n, window, tail) do
    a = Enum.sum(window)
    # shift the window
    [_ | keep] = window
    [next | new_tail] = tail
    new_window = keep ++ [next]
    b = Enum.sum(new_window)
    n = if b > a, do: n + 1, else: n
    count_sliding_increases(n, new_window, new_tail)
  end
end
