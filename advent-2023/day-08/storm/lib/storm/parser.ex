defmodule Storm.Parser do
  @moduledoc """
  Parsing for `Storm`.
  """

  import NimbleParsec

  @doc ~S"""
  Parse the input file.

  Returns a list of `Storm.Map`s.
  """
  def parse_input(input_file, opts \\ []) do
    File.read!(input_file)
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of `Storm.Map`s.
  """
  def parse_input_string(input, _opts \\ []) do
    blocks =
      input
      |> String.split("\n\n", trim: true)
    dirs =
      blocks
      |> List.first()
      |> parse_dirs_line()
    nodes =
      blocks
      |> Enum.drop(1)
      |> List.first()
      |> parse_nodes_block()
    %Storm.Map{dirs: dirs, nodes: nodes}
  end

  @doc ~S"""
  Parse an input line containing a list of directions.

  Returns a list of direction atoms (`:left` or `:right`).

  ## Examples
      iex> parse_dirs_line("LRLLR\n")
      [:left, :right, :left, :left, :right]
  """
  def parse_dirs_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.map(fn ch ->
      case ch do
        76 -> :left
        82 -> :right
        _   -> raise "invalid direction #{ch}"
      end
    end)
  end

  defp parse_nodes_block(block) do
    block
    |> String.trim_trailing()
    |> String.split("\n")
    |> Enum.map(&parse_node_line/1)
    |> Enum.into(%{})
  end

  defparsec :node_name, ascii_string([?A..?Z, ?1..?2], 3)
  defparsec :node_line,
    parsec(:node_name)
    |> ignore(string(" = ("))
    |> parsec(:node_name)
    |> ignore(string(", "))
    |> parsec(:node_name)
    |> ignore(string(")"))

  @doc ~S"""
  Parse an input line containing a node description.

  Returns a `{source, destinations}` pair.

  ## Examples
      iex> parse_node_line("AAA = (BBB, CCC)\n")
      {"AAA", {"BBB", "CCC"}}
      iex> parse_node_line("11A = (11B, XXX)\n")
      {"11A", {"11B", "XXX"}}
  """
  def parse_node_line(line) do
    {:ok, [s, d1, d2], _, _, _, _} =
      line
      |> String.trim_trailing()
      |> node_line()
    {s, {d1, d2}}
  end
end
