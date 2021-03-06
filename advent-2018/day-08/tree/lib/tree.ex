defmodule Tree do
  @moduledoc """
  Documentation for Tree.
  """

  import Tree.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, parts} = parse_args(argv)
    if Enum.member?(parts, 1),
      do: part1(input_file)
    if Enum.member?(parts, 2),
      do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: 41760
  """
  def part1(input_file) do
    input_file
    |> File.read!
    |> parse_integers
    |> build_tree
    |> meta_sum
    |> IO.inspect(label: "Part 1 metadata sum is")
  end

  @doc """
  Parse string to list of integers.

  ## Parameters

  - str: The string

  ## Returns

  The list of integers
  """
  def parse_integers(str) do
    str
    |> String.trim
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp meta_sum({childmap, metas}) do
    child_sum = childmap
                |> Enum.reduce(0, fn ({_k, child}, acc) -> acc + meta_sum(child) end)
    child_sum + Enum.sum(metas)
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: 25737
  """
  def part2(input_file) do
    input_file
    |> File.read!
    |> parse_integers
    |> build_tree
    |> meta_sum_p2
    |> IO.inspect(label: "Part 2 metadata sum is")
  end

  defp meta_sum_p2({childmap, metas}) do
    if map_size(childmap) == 0 do
      # If a node has no child nodes, its value is the sum of its metadata
      # entries.
      Enum.sum(metas)
    else
      # If a node does have child nodes, the metadata entries become indexes
      # which refer to those child nodes.
      metas
      |> Enum.reduce(0, fn (meta, acc) ->
        # If a referenced child node does not exist, that reference is
        # skipped. A metadata entry of 0 does not refer to any child node.
        if childmap[meta], do: meta_sum_p2(childmap[meta]) + acc, else: acc
      end)
    end
  end

  @doc """
  Reduce input list to node tree structure. The input takes the form:

  ```
  n_children n_meta <child_1> <child_2> ... <child_n> meta_1 meta_2 ... meta_n
  ```

  where each `<child_x>` is a nested example of the same form.

  ## Parameters

  - input: Input values (list of integers)

  ## Returns

  Node structure in the form {%{<children>}, [<metas>]}
  """
  def build_tree(input) do
    {children, metas, []} = build_node(input)
    {children, metas}
  end

  # NB returns a child, with its children as **map**
  defp build_node([n_children | [n_meta | input]]) do
    {children, input} = build_children(n_children, input)
    {metas, input} = Enum.split(input, n_meta)
    childmap = Enum.reverse(children)
               |> Enum.reduce({%{}, 1}, fn (child, {map, i}) ->
                 {Map.put(map, i, child), i+1}
               end)
               |> elem(0)
    {childmap, metas, input}
  end

  # NB returns children as **list**
  defp build_children(0, input) do
    {[], input}
  end

  # NB returns children as **list**
  defp build_children(n_children, input) do
    1..n_children
    |> Enum.reduce({[], input}, fn (_child_n, {children, remainder}) ->
      {childmap, metas, remainder} = build_node(remainder)
      {[{childmap, metas} | children], remainder}
    end)
  end
end
