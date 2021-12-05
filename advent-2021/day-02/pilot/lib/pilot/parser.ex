defmodule Pilot.Parser do
  @moduledoc """
  Parsing for `Pilot`.
  """

  @doc ~S"""
  Parse the input file.
  """
  def parse_input(input_file, opts \\ []) do
    input_file
    |> File.stream!
    |> parse_lines(opts)
  end

  @doc ~S"""
  Parse input lines.
  """
  def parse_lines(lines, _opts \\ []) do
    lines
    |> Enum.map(&Pilot.Parser.parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing direction and magnitude.

  Returns `{x, y}` position change.

  ## Examples
      iex> Pilot.Parser.parse_line("forward 2")
      {2, 0}
      iex> Pilot.Parser.parse_line("up 3")
      {0, -3}
  """
  def parse_line(line) do
    Regex.run(~r/^(\w+)\s+(\d+)/, line)
    |> (fn [_, dir, mag] -> {dir, String.to_integer(mag)} end).()
    |> parse_step
  end
  defp parse_step({dir, mag}) when dir == "forward", do: {mag, 0}
  defp parse_step({dir, mag}) when dir == "down", do: {0, mag}
  defp parse_step({dir, mag}) when dir == "up", do: {0, -mag}
end
