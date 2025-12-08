defmodule Wire do
  @moduledoc """
  Documentation for `Wire`.
  """

  import Wire.Parser
  import Decor.CLI
  import Decor.Math

  @doc """
  Find the N closest pairs of junction boxes.
  """
  def n_closest_box_pairs(boxes, n) do
    boxes
    |> Enum.sort()
    |> box_pair_distances([])
    |> Enum.sort(fn a, b -> elem(a, 0) < elem(b, 0) end)
    |> Enum.map(fn {_dist, a, b} -> {a, b} end)
    |> Enum.take(n)
  end

  defp box_pair_distances([next_box, rem_box], acc) do
    dist = {euclidean_dist(next_box, rem_box), next_box, rem_box}
    [dist | acc]
  end
  defp box_pair_distances([next_box | rem_boxes], acc) do
    acc =
      rem_boxes
      |> Enum.reduce(acc, fn rem_box, acc ->
        dist = {euclidean_dist(next_box, rem_box), next_box, rem_box}
        [dist | acc]
      end)
    box_pair_distances(rem_boxes, acc)
  end

  @doc """
  Connect pairs of junction boxes into circuits.
  """
  def connect_circuits(box_pairs) do
    box_pairs
    |> Enum.reduce(%{}, fn {a, b}, acc ->
      a_circ = Map.get(acc, a)
      b_circ = Map.get(acc, b)
      cond do
        a_circ && b_circ && (a_circ == b_circ) ->
          acc
        a_circ && b_circ && (a_circ != b_circ) ->
          join_circuits(acc, a_circ, b_circ)
        a_circ ->
          Map.put(acc, b, a_circ)
        b_circ ->
          Map.put(acc, a, b_circ)
        true ->
          Map.put(acc, a, a)
          |> Map.put(b, a)
      end
    end)
  end

  defp join_circuits(acc, a_circ, b_circ) do
    Map.keys(acc)
    |> Enum.reduce(acc, fn k, acc ->
      if Map.get(acc, k) == b_circ do
        Map.put(acc, k, a_circ)
      else
        acc
      end
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
    |> n_closest_box_pairs(1000)
    |> connect_circuits()
    |> Enum.count()  # TODO get three largest circuits
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
