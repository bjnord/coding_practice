defmodule Yard do
  @doc ~S"""
  Parses a line from the initial state, adding its data to an accumulator.

  ## Example

      iex> Yard.parse_line(".#.#...|#.", 42, %{})
      %{
        {42, 0} => :open,
        {42, 1} => :lumber,
        {42, 2} => :open,
        {42, 3} => :lumber,
        {42, 4} => :open,
        {42, 5} => :open,
        {42, 6} => :open,
        {42, 7} => :wooded,
        {42, 8} => :lumber,
        {42, 9} => :open,
      }

  """
  def parse_line(line, y, grid) when is_binary(line) do
    line
    |> String.trim_trailing
    |> String.graphemes
    |> Enum.with_index
    |> Enum.reduce(grid, fn ({cell, x}, grid_a) ->
      Map.put(grid_a, {y, x}, cell_type(cell))
    end)
  end

  defp cell_type(cell) do
    case cell do
      "." -> :open
      "|" -> :wooded
      "#" -> :lumber
    end
  end
end
