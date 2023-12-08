defmodule Storm.Map do
  @moduledoc """
  Map structure and functions for `Storm`.
  """

  defstruct dirs: [], nodes: []

  @doc ~S"""
  Calculate steps taken by following a map.

  ## Parameters

  - `map` - a `Map`

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
end
