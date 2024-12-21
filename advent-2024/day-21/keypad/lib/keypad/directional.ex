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

  def move_permutations({from, to}) do
    {fy, fx} = location(from)
    {ty, tx} = location(to)
    {dy, dx} = {ty - fy, tx - fx}
    move_permutations =
      cond do
        (from == ?<) ->
          [horiz_moves(dx) ++ vert_moves(dy)]
        ((from == ?^) || (from == ?A)) && (to == ?<) ->
          [vert_moves(dy) ++ horiz_moves(dx)]
        true ->
          [
            horiz_moves(dx) ++ vert_moves(dy),
            vert_moves(dy) ++ horiz_moves(dx),
          ]
          |> Enum.uniq()
      end
    move_permutations
    |> Enum.map(&(sanity_check(&1, {fy, fx})))
  end

  defp sanity_check(moves, {y, x}) do
    moves
    |> Enum.reduce({y, x}, fn move, {y, x} ->
      {ny, nx} =
        case move do
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
    moves
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
