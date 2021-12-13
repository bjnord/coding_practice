defmodule Origami.Parser do
  @moduledoc """
  Parsing for `Origami`.
  """

  @doc ~S"""
  Parse input as a block string.

  ## Examples
      iex> Origami.Parser.parse_input_string("1,2\n3,4\n\nfold along x=5\nfold along y=6\n")
      {
        [{1, 2}, {3, 4}],
        [{:fold_x, 5}, {:fold_y, 6}],
      }
  """
  def parse_input_string(input) do
    {points, instructions} =
      input
      |> String.split("\n\n")
      |> List.to_tuple()
    points =
      points
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_point/1)
    instructions =
      instructions
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_instruction/1)
    {points, instructions}
  end
  defp parse_point(line) do
    line
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
  defp parse_instruction(line) do
    Regex.run(~r/^fold\s+along\s+(\w)=(\d+)/, line)
    |> (fn [_, xy, n] ->
      {String.to_atom("fold_#{xy}"), String.to_integer(n)}
    end).()
  end
end
