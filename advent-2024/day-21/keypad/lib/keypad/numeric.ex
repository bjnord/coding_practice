defmodule Keypad.Numeric do
  @moduledoc """
  Functions for a numeric keypad.

  ```
  +---+---+---+
  | 7 | 8 | 9 |
  +---+---+---+
  | 4 | 5 | 6 |
  +---+---+---+
  | 1 | 2 | 3 |
  +---+---+---+
      | 0 | A |
      +---+---+
  ```
  """

  def move_permutations({from, to}) do
    {fy, fx} = location(from)
    {ty, tx} = location(to)
    {dy, dx} = {ty - fy, tx - fx}
    move_permutations =
      cond do
        ((from == ?0) || (from == ?A)) && ((to == ?1) || (to == ?4) || (to == ?7)) ->
          [vert_moves(dy) ++ horiz_moves(dx)]
        ((from == ?1) || (from == ?4) || (from == ?7)) && ((to == ?0) || (to == ?A)) ->
          [horiz_moves(dx) ++ vert_moves(dy)]
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
      if {ny, nx} == {3, 0} do
        raise "Numeric robot panic"
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
      ?0 -> {3, 1}
      ?A -> {3, 2}
      ?1 -> {2, 0}
      ?2 -> {2, 1}
      ?3 -> {2, 2}
      ?4 -> {1, 0}
      ?5 -> {1, 1}
      ?6 -> {1, 2}
      ?7 -> {0, 0}
      ?8 -> {0, 1}
      ?9 -> {0, 2}
    end
  end
end
