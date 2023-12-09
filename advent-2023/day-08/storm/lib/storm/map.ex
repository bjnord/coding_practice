defmodule Storm.Map do
  @moduledoc """
  Map structure and functions for `Storm`.
  """

  defstruct dirs: [], nodes: %{}

  @doc ~S"""
  Calculate steps taken by following a map.

  ## Parameters

  - `map` - a `Storm.Map`

  Returns an integer step count.
  """
  def steps(map) do
    Stream.cycle(map.dirs)
    |> Enum.reduce_while({0, "AAA"}, fn dir, {steps, node} ->
      new_node =
        if dir == :left do
          elem(map.nodes[node], 0)
        else
          elem(map.nodes[node], 1)
        end
      steps = steps + 1
      if new_node == "ZZZ" do
        {:halt, steps}
      else
        {:cont, {steps, new_node}}
      end
    end)
  end

  @doc ~S"""
  Find the map nodes whose source ends in "A".

  ## Parameters

  - `map` - a `Storm.Map`

  Returns a list of map nodes whose source ends in "A" (strings).
  """
  def a_nodes(map) do
    map.nodes
    |> Map.keys()
    |> Enum.filter(&is_a?/1)
  end

  defp is_a?(node) do
    String.slice(node, -1..-1) == "A"
  end
  defp is_z?(node) do
    String.slice(node, -1..-1) == "Z"
  end

  @doc ~S"""
  Find the cycle length of an "A" node in a map.

  ## Parameters

  - `map` - a `Storm.Map`
  - `node` - the starting "A" node (string)

  Returns the cycle length (integer).
  """
  def cycle_length(map, node) do
    unless is_a?(node) do
      raise "must be called with 'A' node"
    end
    Stream.cycle(map.dirs)
    |> Enum.reduce_while({0, node, 0, nil}, fn dir, {steps, node, saw_steps, saw_z_node} ->
      # TODO extract code in common with `steps()`
      new_node =
        if dir == :left do
          elem(map.nodes[node], 0)
        else
          elem(map.nodes[node], 1)
        end
      steps = steps + 1
      if is_z?(new_node) do
        if saw_z_node do
          # end of second cycle: assert, and return cycle length
          cond do
            saw_z_node != new_node ->
              raise "first saw #{saw_z_node}, then saw #{new_node} :("
            (saw_steps * 2) != steps ->
              raise "first cycle steps #{saw_steps}, total steps #{steps} :("
            true ->
              {:halt, saw_steps}
          end
        else
          # end of first cycle: record this Z
          {:cont, {steps, new_node, steps, new_node}}
        end
      else
        # middle of cycle: keep going
        {:cont, {steps, new_node, saw_steps, saw_z_node}}
      end
    end)
  end
end
