defmodule Beacon do
  @moduledoc """
  Documentation for Beacon.
  """

  alias Beacon.Parser, as: Parser
  alias Beacon.Transformer, as: Transformer
  import Submarine.CLI

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
    scanners =
      File.read!(input_file)
      |> Parser.parse()
    experiment(scanners)  # FIXME TEMP DEBUG
    nil  # TODO
    |> IO.inspect(label: "Part 1 answer is")
  end

  def experiment(scanners) do
    scanner0_count = Enum.count(scanners[0])
                     |> IO.inspect(label: "scanners[0] count")
    scanner1_count = Enum.count(scanners[1])
                     |> IO.inspect(label: "scanners[1] count")
    offsets =
      scanners[1]  # positions
      |> Enum.flat_map(fn s1_pos ->
        s1_pos
        |> Transformer.transforms()
        |> Enum.flat_map(fn {t, s1_rot_pos} ->
          scanners[0]  # positions
          |> Enum.map(fn s0_pos -> {t, sub_pos(s0_pos, s1_rot_pos)} end)
        end)
      end)
    IO.inspect(Enum.count(offsets), label: "n_offsets")
    IO.inspect(scanner0_count * scanner1_count * 24, label: "exp_n_offsets")
    offset_counts =
      offsets
      |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    [hi_key | _other_keys] =
      offset_counts
      |> Enum.map(fn {k, v} -> {k, v} end)
      |> Enum.sort_by(fn {_k, v} -> -v end)
      |> Enum.map(&(elem(&1, 0)))
    IO.inspect({hi_key, offset_counts[hi_key]}, label: "highest transform,pos and count")
  end
  defp sub_pos({i0, j0, k0}, {i1, j1, k1}) do
    {i0 - i1, j0 - j1, k0 - k1}
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
