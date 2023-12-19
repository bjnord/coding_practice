defmodule Parts.Rules do
  @moduledoc """
  Workflow functions for `Parts`.
  """

  @doc ~S"""
  Calculate the sum of the rating of all accepted parts.

  ## Parameters

  A tuple with these elements:
  - `workflows`: the workflows (map)
  - `parts`: the parts (list of keyword maps)

  Returns the rating sum (integer).
  """
  def accepted_rating({workflows, parts}) do
    part_decisions =
      parts
      |> Enum.map(fn part -> flow(workflows, part) end)
    [parts, part_decisions]
    |> Enum.zip()
    |> Enum.map(fn {part, decision} ->
      if decision == :accept do
        part.x + part.m + part.a + part.s
      else
        0
      end
    end)
    |> Enum.sum()
  end

  @doc ~S"""
  Process workflows for the given part.

  ## Parameters

  - `part`: the part

  Returns a decision (`:accept` or `:reject`).
  """
  def flow(workflows, part, flow \\ :in) do
    workflows[flow]
    |> Enum.reduce_while(nil, fn rule, acc ->
      next = rule(part, rule)
      cond do
        final?(next) ->
          {:halt, next}
        next ->
          {:halt, flow(workflows, part, next)}
        true ->
          {:cont, acc}
      end
    end)
  end

  defp rule(part, {attr, op, value, next}) do
    pv = part[attr]
    cond do
      (op == ?<) && (pv < value) ->
        next
      (op == ?>) && (pv > value) ->
        next
      true ->
        nil
    end
  end
  defp rule(_part, decision), do: decision

  defp final?(:accept), do: true
  defp final?(:reject), do: true
  defp final?(_), do: false
end
