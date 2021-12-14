defmodule Polymer.Stepper do
  @moduledoc """
  Stepper for `Polymer`.
  """

  defstruct template_elements: [], rules: %{}, pair_counts: %{}

  @doc ~S"""
  Create new stepper from `input`.

  ## Examples
      iex> stepper = Polymer.Stepper.new("AABAA\n\nAA -> C\nAB -> C\nBA -> A\n")
      iex> stepper.template_elements
      [?A, ?A, ?B, ?A, ?A]
      iex> stepper.pair_counts
      %{{?A, ?A} => 2, {?A, ?B} => 1, {?B, ?A} => 1}
  """
  def new(input) do
    {template, rules} = Polymer.Parser.parse_input_string(input)
    template_elements = String.to_charlist(template)
    pairs =
      template_elements
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&List.to_tuple/1)
    pair_counts =
      pairs
      |> Enum.reduce(%{}, fn (pair, map) ->
        Map.update(map, pair, 1, &(&1 + 1))
      end)
    %Polymer.Stepper{
      template_elements: template_elements,
      rules: rules,
      pair_counts: pair_counts,
    }
  end

  @doc ~S"""
  Perform `n` steps of polymer insertion.
  """
  def step(stepper \\ n = 1) do
    stepper  # TODO
  end

  @doc ~S"""
  Count elements in current polymer.

  ## Examples
      iex> stepper = Polymer.Stepper.new("AABA\n\nAA -> C\nAB -> C\nBA -> A\n")
      iex> Polymer.Stepper.element_count(stepper)
      %{?A => 3, ?B => 1}
  """
  def element_count(stepper) do
    ###
    # find the first/last elements of the original template
    {first, last} = {
      List.first(stepper.template_elements),
      List.last(stepper.template_elements),
    }
    ###
    # 1. sum up element counts of all pairs
    #    (_e.g._ `{?A, ?B} => 2` means two more As and two more Bs)
    # 1. the first/last template elements will only be in one pair
    #    (so add one to round the count up)
    double_counts =
      stepper.pair_counts
      |> Enum.reduce(%{}, fn ({{a, b}, count}, map) ->
        Map.update(map, a, count, &(&1 + count))
        |> Map.update(b, count, &(&1 + count))
      end)
      |> (fn map -> Map.update!(map, first, &(&1 + 1)) end).()
      |> (fn map -> Map.update!(map, last, &(&1 + 1)) end).()
    ###
    # then we just have to divide all counts by 2
    Map.keys(double_counts)
    # TODO Elixir v1.13 has `Map.map()`
    |> Enum.reduce(%{}, fn (k, map) -> Map.put(map, k, div(double_counts[k], 2)) end)
  end

  @doc """
  Find the minimum and maximum number of element occurrences in the current
  polymer.
  """
  def min_max(stepper) do
    counts = element_count(stepper)
    min = Enum.min(Map.values(counts))
    max = Enum.max(Map.values(counts))
    {min, max}
  end
end
