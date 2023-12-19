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

  @doc ~S"""
  Find the rule-ranges for a workflow.

  ## Parameters

  - `rules`: the list of workflow rules

  Returns the rule-ranges (list).
  """
  def rule_ranges(rules) do
    rules
    |> Enum.reduce({full_ranges(), []}, fn rule, {ranges, rule_ranges} ->
      {rr1, flow, rr2} = split_rule_ranges(rule, ranges)
      {rr2, [{rr1, flow} | rule_ranges]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  defp full_ranges() do
    %{
      x: {1, 4000},
      m: {1, 4000},
      a: {1, 4000},
      s: {1, 4000},
    }
  end

  defp split_rule_ranges({attr, op, value, flow}, ranges) do
    {min, max} = ranges[attr]
    if (value <= min) || (value >= max) do
      raise "split value out of range #{min} < #{value} < #{max}"
    end
    {r1_ranges, r2_ranges} =
      if op == ?< do
        {
          %{ranges | attr => {min, value - 1}},
          %{ranges | attr => {value, max}},
        }
      else  # ?>
        {
          %{ranges | attr => {value + 1, max}},
          %{ranges | attr => {min, value}},
        }
      end
    {r1_ranges, flow, r2_ranges}
  end
  defp split_rule_ranges(flow, ranges) do
    {ranges, flow, nil}
  end

  @doc ~S"""
  Find the intersection of two range sets.

  ## Parameters

  - `a`: the first range set (keyword map)
  - `b`: the second range set (keyword map)

  Returns the intersection (keyword map).
  """
  def intersection(a, b) do
    [:x, :m, :a, :s]
    |> Enum.reduce(%{}, fn attr, ranges ->
      Map.put(ranges, attr, range_intersection(a[attr], b[attr]))
    end)
  end

  defp range_intersection({a_min, a_max}, {b_min, b_max}) do
    cond do
      a_min > a_max ->
        raise "invalid A range {#{a_min}, #{a_max}}"
      b_min > b_max ->
        raise "invalid B range {#{b_min}, #{b_max}}"
      ###
      # no overlap
      (a_min <= b_min) && (a_max < b_min) ->
        {0, 0}
      (b_min <= a_min) && (b_max < a_min) ->
        {0, 0}
      ###
      # containment
      (a_min >= b_min) && (a_max <= b_max) ->
        {a_min, a_max}
      (b_min >= a_min) && (b_max <= a_max) ->
        {b_min, b_max}
      ###
      # overlap
      a_min <= b_min ->
        {b_min, a_max}
      true ->  # b_min <= a_min
        {a_min, b_max}
    end
  end

  @doc ~S"""
  Find the number of distinct accepted combinations of the given workflows.

  ## Parameters

  - `workflows`: the workflows (map)

  Returns the distinct accepted combinations (integer).
  """
  def distinct_combos(workflows) do
    distinct_combos(workflows, :in, full_ranges())
  end

  defp distinct_combos(_workflows, :reject, _in_ranges), do: 0
  defp distinct_combos(_workflows, :accept, in_ranges) do
    [:x, :m, :a, :s]
    |> Enum.reduce([], fn attr, combos ->
      {min, max} = in_ranges[attr]
      new_combos =
        cond do
          min == 0 -> 0
          max == 0 -> 0
          true     -> (max - min + 1)
        end
      [new_combos | combos]
    end)
    |> Enum.product()
  end
  defp distinct_combos(workflows, flow, in_ranges) do
    workflows[flow]
    |> rule_ranges()
    |> Enum.reduce(0, fn {r_ranges, r_flow}, combos ->
      int_ranges = intersection(in_ranges, r_ranges)
      new_combos = distinct_combos(workflows, r_flow, int_ranges)
      combos + new_combos
    end)
  end
end
