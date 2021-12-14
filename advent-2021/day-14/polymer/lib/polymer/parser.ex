defmodule Polymer.Parser do
  @moduledoc """
  Parsing for `Polymer`.
  """

  @doc ~S"""
  Parse input as a block string.

  ## Examples
      iex> Polymer.Parser.parse_input_string("AABA\n\nAA -> C\nAB -> C\nBA -> A\n")
      {"AABA", %{
        {?A, ?A} => ?C,
        {?A, ?B} => ?C,
        {?B, ?A} => ?A,
      }}
  """
  def parse_input_string(input, _opts \\ []) do
    [template | [rule_lines | _tail]] = String.split(input, "\n\n")
    rules =
      rule_lines
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_rule_line/1)
      |> Enum.into(%{})
    {template, rules}
  end
  defp parse_rule_line(line) do
    [k | [v | _tail]] =
      line
      |> String.trim_trailing()
      |> String.split(" -> ")
    key = String.to_charlist(k) |> List.to_tuple()
    value = String.to_charlist(v) |> List.first()
    {key, value}
  end
end
