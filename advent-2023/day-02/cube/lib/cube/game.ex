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

  @doc """
  Would game have been possible if the bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?

  ## Examples

      iex> %Cube.Game{id: 2, max_reveal: %{blue: 2, green: 4, red: 3}} |> Cube.Game.possible?()
      true
      iex> %Cube.Game{id: 3, max_reveal: %{blue: 12, green: 14, red: 13}} |> Cube.Game.possible?()
      false
  """
  def possible?(game) do
    cond do
      game.max_reveal.red > 12   -> false
      game.max_reveal.green > 13 -> false
      game.max_reveal.blue > 14  -> false
      true                       -> true
    end
  end

  @doc """
  Calculate power of a set of cubes.

  ## Examples

      iex> %Cube.Game{id: 2, max_reveal: %{blue: 2, green: 4, red: 3}} |> Cube.Game.cube_power()
      24
  """
  def cube_power(game) do
    game.max_reveal.red * game.max_reveal.green * game.max_reveal.blue
  end
end
