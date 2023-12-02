defmodule Cube.Game do
  @moduledoc """
  Game structure and functions for `Cube`.
  """

  defstruct id: 0, reveals: [], max_reveal: %{red: 0, blue: 0, green: 0}
  alias Cube.Game, as: Game

  @doc """
  Calculate maximum number of cube types revealed during game.

  ## Examples

      iex> %Cube.Game{id: 2, reveals: [%{blue: 2, green: 1}, %{green: 4, red: 3}]} |> Cube.Game.max()
      %Cube.Game{id: 2, max_reveal: %{blue: 2, green: 4, red: 3}}
  """
  def max(game) do
    max_reveal =
      game.reveals
      |> Enum.reduce(game.max_reveal, fn r, max ->
        %{
          red: max_reveal_value(r, max, :red),
          blue: max_reveal_value(r, max, :blue),
          green: max_reveal_value(r, max, :green),
        }
      end)
    %Game{
      id: game.id,
      max_reveal: max_reveal
    }
  end

  defp max_reveal_value(a, b, key) do
    cond do
      a[key] == nil   -> b[key]
      b[key] == nil   -> a[key]
      a[key] > b[key] -> a[key]
      true            -> b[key]
    end
  end
end
