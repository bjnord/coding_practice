defmodule Octopus.Grid do
  @moduledoc """
  Grid structure for `Octopus`.
  """

  defstruct dim: 0, grid: {}, flashes: 0

  @doc ~S"""
  Construct a new grid from 2D input.

  ## Examples
      iex> Octopus.Grid.new({{0, 1}, {2, 3}})
      %Octopus.Grid{dim: 2, grid: {{0, 1}, {2, 3}}, flashes: 0}
  """
  def new(input) do
    %Octopus.Grid{
      grid: input,
      dim: tuple_size(input),
    }
  end
end
