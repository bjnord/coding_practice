defmodule Sand.Parser do
  @moduledoc """
  Parsing for `Sand`.
  """

  alias Sand.Brick

  @doc ~S"""
  Parse the input file.

  Returns a list of `Brick`s (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of `Brick`s (one per line).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a brick.

  Returns a `Brick`.

  ## Examples
      iex> parse_line("5,4,2~7,6,2\n")
      %Sand.Brick{from: %{x: 5, y: 4, z: 2}, to: %{x: 7, y: 6, z: 2}}
  """
  def parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split("~")
    |> Enum.map(&parse_coordinates/1)
    |> then(fn [from, to] ->
      if from.z > to.z do
        raise "swapped Z #{from.z} > #{to.z}"
      end
      if from.x > to.x do
        raise "swapped X #{from.x} > #{to.x}"
      end
      if from.y > to.y do
        raise "swapped Y #{from.y} > #{to.y}"
      end
      %Brick{from: from, to: to}
    end)
  end

  defp parse_coordinates(coord) do
    coord
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> then(fn [x, y, z] ->
      %{x: x, y: y, z: z}
    end)
  end
end
