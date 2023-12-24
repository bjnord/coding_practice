defmodule Hail do
  @moduledoc """
  Documentation for `Hail`.
  """

  import Hail.Parser
  import Snow.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    parse_input(input_file)
    nil  # TODO
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    parse_input(input_file)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Find the 2D intersection point of two hailstones.

  Returns a `{x, y}` (floating-point).
  Returns `{nil, nil}` for parallel lines that don't intersect.
  Returns `{nil, nil}` for horizontal lines (infinite slope).
  """
  def intersect_2d({{_, _, _}, {0, _, _}}, {{_, _, _}, {_bdx, _, _}}), do: {nil, nil}
  def intersect_2d({{_, _, _}, {_adx, _, _}}, {{_, _, _}, {0, _, _}}), do: {nil, nil}
  def intersect_2d({{ax, ay, _}, {adx, ady, _}}, {{bx, by, _}, {bdx, bdy, _}}) do
    am = fp(ady) / fp(adx)
    ab = fp(ay) - (am * fp(ax))
    bm = fp(bdy) / fp(bdx)
    bb = fp(by) - (bm * fp(bx))
    if abs(am - bm) < 0.000_000_001 do
      {nil, nil}
    else
      x = (bb - ab) / (am - bm)
      y = am * x + ab
      {x, y}
    end
  end

  defp fp(i), do: (i * 1.0)
end
