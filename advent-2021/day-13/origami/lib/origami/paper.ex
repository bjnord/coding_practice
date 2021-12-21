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

  @doc ~S"""
  Fold origami `paper` according to the given instruction.
  """
  def fold(paper, {dir, ypos}) when dir == :fold_y do
    new_points =
      paper.points
      |> Enum.map(fn {x, y} ->
        cond do
          y > ypos -> {x, y - (y - ypos) * 2}
          true -> {x, y}
        end
      end)
      |> Enum.sort()
      |> Enum.uniq()
    %Origami.Paper{
      points: new_points,
      dimx: paper.dimx,
      dimy: ypos,
    }
  end
  def fold(paper, {dir, xpos}) when dir == :fold_x do
    new_points =
      paper.points
      |> Enum.map(fn {x, y} ->
        cond do
          x > xpos -> {x - (x - xpos) * 2, y}
          true -> {x, y}
        end
      end)
      |> Enum.sort()
      |> Enum.uniq()
    %Origami.Paper{
      points: new_points,
      dimx: xpos,
      dimy: paper.dimy,
    }
  end

  @doc ~S"""
  Fold origami `paper` according to the given `instructions`.
  """
  def fold(paper, instructions) do
    instructions
    |> Enum.reduce(paper, fn (instruction, paper) ->
      fold(paper, instruction)
    end)
  end

  @doc ~S"""
  Return number of points on `paper`.
  """
  def n_points(paper), do: Enum.count(paper.points)

  @doc """
  Render paper to text.
  """
  def render(paper) do
    paper_points(paper.dimx, paper.dimy)
    |> Enum.reduce([], fn (point, chars) ->
      case Enum.find(paper.points, fn p -> p == point end) do
        nil -> [?. | chars]
        _ -> [?# | chars]
      end
    end)
    |> Enum.reverse
    |> Enum.chunk_every(paper.dimx)
    |> Enum.map(fn chars -> to_string(chars) end)
    |> Enum.join("\n")
    |> (fn text -> "#{text}\n" end).()
  end

  defp paper_points(dimx, dimy) do
    for y <- 0..dimy-1, x <- 0..dimx-1 do
      {x, y}
    end
  end
end
