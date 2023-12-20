defmodule Pulse.Parser do
  @moduledoc """
  Parsing for `Pulse`.
  """

  alias Pulse.Network

  @doc ~S"""
  Parse the input file.

  Returns a list of charlists (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
    |> Enum.into(%{})
    |> then(fn modules -> %Network{modules: modules} end)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of charlists (one per line).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
    |> Enum.into(%{})
    |> then(fn modules -> %Network{modules: modules} end)
  end

  @doc ~S"""
  Parse an input line containing a network module.

  Returns a tuple with these elements:
  - `name`: the module name (atom)
  - `{type, destinations}`: the module type (atom) and list of pulse
    destination modules (atoms)

  ## Examples
      iex> parse_line("broadcaster -> a\n")
      {:broadcaster, {:broadcast, [:a]}}
      iex> parse_line("%a -> inv, con\n")
      {:a, {:flipflop, [:inv, :con]}}
  """
  def parse_line(line) do
    Regex.split(~r{\s+->\s+}, String.trim_trailing(line))
    |> then(fn [t_name, dests] ->
      {type, name} = parse_type_name(t_name)
      destinations =
        Regex.split(~r{,\s+}, dests)
        |> Enum.map(&String.to_atom/1)
      {String.to_atom(name), {type, destinations}}
    end)
  end

  defp parse_type_name(t_name) do
    {type, name} = split_type_name(t_name)
    case type do
      "%" -> {:flipflop,    name}
      "&" -> {:conjunction, name}
      _   -> {:broadcast,   t_name}
    end
  end

  defp split_type_name(s) do
    {
      String.slice(s, 0..0),
      String.slice(s, 1..(String.length(s) - 1)),
    }
  end
end
