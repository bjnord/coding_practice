defmodule Springs.Parser do
  @moduledoc """
  Parsing for `Springs`.
  """

  alias Springs.Row

  @doc ~S"""
  Parse the input file.

  Returns a list of `Row`s (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of `Row`s (one per line).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a row of springs and counts.

  Returns a `Row`.

  ## Examples
      iex> parse_line(".??..??...?##. 1,1,3\n")
      %Springs.Row{clusters: ['??', '??', '?##'], counts: [1, 1, 3]}
      iex> parse_line("?#?#?#?#?#?#?#? 1,3,1,6\n")
      %Springs.Row{clusters: ['?#?#?#?#?#?#?#?'], counts: [1, 3, 1, 6]}
  """
  def parse_line(line) do
    [clusters, counts] =
      line
      |> String.trim_trailing()
      |> String.split()
    %Row{
      clusters: parse_clusters(clusters),
      counts: parse_counts(counts),
    }
  end

  defp parse_clusters(clusters) do
    clusters
    |> String.split(".")
    |> Enum.reject(fn s -> s == "" end)
    |> Enum.map(&String.to_charlist/1)
  end

  defp parse_counts(counts) do
    counts
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
