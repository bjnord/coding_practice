defmodule Origami.Paper do
  @moduledoc """
  Parsing for `Origami`.
  """

  defstruct dimx: 0, dimy: 0, points: {}

  @doc ~S"""
  Parse input as a block string.

  ## Examples
      iex> Origami.Paper.parse_input_string("1,2\n4,6\n\nfold along x=2\nfold along y=3\n")
      {
        %Origami.Paper{
          dimx: 5,
          dimy: 7,
          points: [{1, 2}, {4, 6}],
        },
        [{:fold_x, 2}, {:fold_y, 3}],
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
    {maxx, maxy} =
      points
      |> Enum.reduce({0, 0}, fn ({x, y}, {maxx, maxy}) ->
        maxx = max(maxx, x)
        maxy = max(maxy, y)
        {maxx, maxy}
      end)
    instructions =
      instructions
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_instruction/1)
    {
      %Origami.Paper{dimx: maxx + 1, dimy: maxy + 1, points: points},
      instructions
    }
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
