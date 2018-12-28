defmodule Dimension do
  @moduledoc """
  Documentation for Dimension.
  """

  import Dimension.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1),
      do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2),
      do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: 338
  """
  def part1(input_file, _opts \\ []) do
    input_file
    |> parse_input_file()
    |> form_constellations()
    |> repeatedly_merge_constellations()
    |> Enum.count()
    |> IO.inspect(label: "Part 1 number of constellations is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file, _opts \\ []) do
    ans_type = "???"
    input_file
    |> IO.inspect(label: "Part 2 #{ans_type} is")
  end

  @doc """
  Parse input file.
  """
  def parse_input_file(input_file) do
    input_file
    |> File.stream!
    |> Enum.map(&String.trim/1)
    |> Enum.map(&(String.split(&1, ",")))
    |> Enum.map(fn (dims) ->
      Enum.map(dims, &(String.to_integer(&1)))
    end)
  end

  @doc """
  Compute the Manhattan distance between two 4-D points.

  "Take the sum of the absolute values of the differences of the coordinates.
  For example, if x=(a,b) and y=(c,d), the Manhattan distance between x and y is |a−c|+|b−d|."
  <https://math.stackexchange.com/a/139604>

  ## Example

  iex> Dimension.manhattan([1, 2, 3, 5], [2, 3, 4, 7])
  5
  """
  def manhattan([w1, x1, y1, z1], [w2, x2, y2, z2]) do
    abs(w1 - w2) + abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  @doc """
  Form constellations.
  """
  def form_constellations(points) do
    points
    |> Enum.reduce([], fn (point, constellations) ->
      add_to_a_constellation(constellations, point)
    end)
  end

  defp add_to_a_constellation(constellations, p) do
    {consns, p_added} =
      constellations
      |> Enum.reduce({[], false}, fn (c, {new_consns, p_added}) ->
        cond do
          p_added ->
            {[c | new_consns], true}
          !p_added && in_constellation?(c, p) ->
            {[[p | c] | new_consns], true}
          true ->
            {[c | new_consns], false}
        end
      end)
    if p_added, do: consns, else: [[p] | consns]
  end

  defp in_constellation?(cons, p) do
    Enum.any?(cons, fn (cp) -> manhattan(cp, p) <= 3 end)
  end

  defp repeatedly_merge_constellations(cons) do
    Stream.cycle([true])
    |> Enum.reduce_while({cons, Enum.count(cons)}, fn (_t, {cons, min_count}) ->
      new_cons = merge_constellations(cons)
      new_count = Enum.count(new_cons)
      if new_count < min_count do
        {:cont, {new_cons, new_count}}
      else
        {:halt, new_cons}
      end
    end)
  end

  defp merge_constellations(constellations) do
    constellations
    |> Enum.reduce([], fn (c, new_consns) ->
      ovl = Enum.find(new_consns, fn (nc) -> overlaps?(c, nc) end)
            #|> IO.inspect(label: "overlaps #{inspect(c)}")
      if ovl do
        [c ++ ovl | List.delete(new_consns, ovl)]
      else
        [c | new_consns]
      end
    end)
  end

  defp overlaps?(cons1, cons2) do
    Enum.any?(cons1, fn (p) -> in_constellation?(cons2, p) end)
  end
end
