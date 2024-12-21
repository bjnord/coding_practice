defmodule Keypad.Directional do
  @moduledoc """
  Functions for a directional keypad.

  ```
      +---+---+
      | ^ | A |
  +---+---+---+
  | < | v | > |
  +---+---+---+
  ```
  """

  def motions({from, to}) do
    {fy, fx} = location(from)
    {ty, tx} = location(to)
    {dy, dx} = {ty - fy, tx - fx}
    motions =
      cond do
        (from == ?^) || (from == ?A) ->
          vert_moves(dy) ++ horiz_moves(dx)
        true ->
          horiz_moves(dx) ++ vert_moves(dy)
      end
    sanity_check(motions, {fy, fx})
    motions
  end

  defp sanity_check(motions, {y, x}) do
    motions
    |> Enum.reduce({y, x}, fn motion, {y, x} ->
      {ny, nx} =
        case motion do
          ?^ -> {y-1, x}
          ?v -> {y+1, x}
          ?< -> {y, x-1}
          ?> -> {y, x+1}
        end
      if {ny, nx} == {0, 0} do
        raise "Directional robot panic"
      end
      {ny, nx}
    end)
  end

  defp vert_moves(dy) when dy == 0, do: []
  defp vert_moves(dy) do
    Enum.reduce(1..abs(dy), [], fn _, acc -> [vert_move(dy) | acc] end)
  end

  defp vert_move(dy) when dy < 0, do: ?^
  defp vert_move(dy) when dy > 0, do: ?v

  defp horiz_moves(dx) when dx == 0, do: []
  defp horiz_moves(dx) do
    Enum.reduce(1..abs(dx), [], fn _, acc -> [horiz_move(dx) | acc] end)
  end

  defp horiz_move(dx) when dx < 0, do: ?<
  defp horiz_move(dx) when dx > 0, do: ?>

  def location(key) do
    case key do
      ?^ -> {0, 1}
      ?A -> {0, 2}
      ?< -> {1, 0}
      ?v -> {1, 1}
      ?> -> {1, 2}
    end
  end
end
